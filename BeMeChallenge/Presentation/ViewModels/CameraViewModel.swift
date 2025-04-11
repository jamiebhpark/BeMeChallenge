// CameraViewModel.swift (업데이트)
import Foundation
import Combine
import AVFoundation
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

class CameraViewModel: ObservableObject {
    @Published var capturedImage: UIImage? = nil
    let session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    
    private let storage = Storage.storage()
    private let db = Firestore.firestore()
    
    func configureSession() {
        session.beginConfiguration()
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device)
        else { return }
        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(photoOutput) { session.addOutput(photoOutput) }
        session.commitConfiguration()
        session.startRunning()
    }
    
    func stopSession() {
        session.stopRunning()
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // 업로드 함수 업데이트: 업로드 시작 시간 측정 및 이벤트 로깅
    func uploadPhoto(_ image: UIImage, forChallenge challengeId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let startTime = Date()
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "Upload", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image conversion failed."])))
            return
        }
        let fileName = UUID().uuidString + ".jpg"
        let storageRef = storage.reference().child("user_uploads/\(Auth.auth().currentUser?.uid ?? "unknown")/\(challengeId)/\(fileName)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        storageRef.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let downloadURL = url else {
                    completion(.failure(NSError(domain: "Upload", code: -1, userInfo: [NSLocalizedDescriptionKey: "Download URL is nil."])))
                    return
                }
                let uploadTime = Date().timeIntervalSince(startTime) * 1000 // 밀리초 단위
                AnalyticsManager.shared.logPhotoUpload(challengeId: challengeId, uploadTime: uploadTime)
                self.savePost(forChallenge: challengeId, imageUrl: downloadURL, completion: completion)
            }
        }
    }
    
    private func savePost(forChallenge challengeId: String, imageUrl: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "Upload", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found."])))
            return
        }
        let newPost: [String: Any] = [
            "challengeId": challengeId,
            "userId": userId,
            "imageUrl": imageUrl.absoluteString,
            "createdAt": FieldValue.serverTimestamp(),
            "reactions": [:],
            "reported": false
        ]
        db.collection("challengePosts").addDocument(data: newPost) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let error = error {
            print("Photo capture error: \(error.localizedDescription)")
            return
        }
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
            print("Error converting photo data.")
            return
        }
        DispatchQueue.main.async {
            self.capturedImage = image
        }
    }
}
