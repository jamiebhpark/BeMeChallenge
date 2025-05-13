// Presentation/ViewModels/CameraViewModel.swift
import Foundation
import AVFoundation
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore
import Combine
import UIKit

@MainActor
final class CameraViewModel: NSObject, ObservableObject {
    
    // MARK: Published
    @Published var capturedImage: UIImage?
    @Published private(set) var uploadState: LoadableProgress = .idle
    
    // MARK: Camera Session
    let session = AVCaptureSession()
    private let output  = AVCapturePhotoOutput()
    
    // MARK: Private
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Session
    func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        guard
            let dev = AVCaptureDevice.default(for: .video),
            let inp = try? AVCaptureDeviceInput(device: dev),
            session.canAddInput(inp), session.canAddOutput(output)
        else { session.commitConfiguration(); return }
        
        session.addInput(inp)
        session.addOutput(output)
        session.commitConfiguration()
        session.startRunning()
    }
    func stopSession() { session.stopRunning() }
    
    // MARK: Capture
    func capturePhoto() {
        output.capturePhoto(with: .init(), delegate: self)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput,
                                 didFinishProcessingPhoto photo: AVCapturePhoto,
                                 error: Error?) {
        guard   error == nil,
                let data  = photo.fileDataRepresentation(),
                let image = UIImage(data: data) else { return }
        Task { @MainActor in self.capturedImage = image }
    }
}

// MARK: - Upload
extension CameraViewModel {
    
    /// 업로드를 시작하고 진행률을 `uploadState` 로 발행
    func startUpload(forChallenge cid: String,
                     onDone: @escaping (Bool) -> Void) {
        guard let img = capturedImage else { return }
        uploadState = .running(0)
        
        Task.detached { [weak self] in
            guard let self else { return }
            let result = await self.upload(image: img, challengeId: cid)
            await MainActor.run {
                switch result {
                case .success:
                    self.uploadState = .succeeded ; onDone(true)
                case .failure(let e):
                    self.uploadState = .failed(e) ; onDone(false)
                }
            }
        }
    }
    
    // MARK: async-await 업로드 핵심
    private func upload(image: UIImage,
                        challengeId: String) async -> Result<Void,Error> {
        guard
            let uid = Auth.auth().currentUser?.uid,
            let data = image.resized(maxPixel: 1024).jpegData(compressionQuality: 0.8)
        else { return .failure(simpleErr("인코딩 실패")) }
        
        let ref = Storage.storage()
            .reference()
            .child("user_uploads/\(uid)/\(challengeId)/\(UUID().uuidString).jpg")
        
        do {
            let task = ref.putDataAsync(data)      // ✨ 확장 util (아래)
            for try await progress in task {
                await MainActor.run { self.uploadState = .running(progress) }
            }
            let url  = try await ref.downloadURL()
            try await addPostDoc(uid: uid, cid: challengeId, imageURL: url)
            return .success(())
        } catch { return .failure(error) }
    }
    
    private func addPostDoc(uid: String,
                            cid: String,
                            imageURL: URL) async throws {
        try await db.collection("challengePosts").addDocument(data: [
            "userId": uid,
            "challengeId": cid,
            "imageUrl": imageURL.absoluteString,
            "createdAt": FieldValue.serverTimestamp(),
            "reactions": [String:Int](),
            "reported":  false
        ])
    }
    
    private func simpleErr(_ msg: String) -> NSError {
        NSError(domain: "CameraUpload", code: -1,
                userInfo: [NSLocalizedDescriptionKey: msg])
    }
}
