//  CameraViewModel.swift
//  BeMeChallenge

import Foundation
import AVFoundation
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore   // ← 추가
import UIKit   // ✅ UIImage 사용

final class CameraViewModel: NSObject, ObservableObject {
    
    // MARK: - Published
    @Published var capturedImage: UIImage?
    
    // MARK: - Camera Session
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    
    // Firestore 인스턴스
    private let db = Firestore.firestore()   // ← 추가
    
    // 세션 설정
    func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        guard
            let device = AVCaptureDevice.default(for: .video),
            let input  = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input),
            session.canAddOutput(output)
        else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)
        session.addOutput(output)
        session.commitConfiguration()
        session.startRunning()
    }
    
    func stopSession() {
        session.stopRunning()
    }
    
    // MARK: - Capture
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard
            error == nil,
            let data = photo.fileDataRepresentation(),
            let image = UIImage(data: data)
        else { return }
        DispatchQueue.main.async { self.capturedImage = image }
    }
}

// MARK: - Upload
extension CameraViewModel {
    /// 촬영한 사진을 업로드하고 Firestore의 `challengePosts` 컬렉션에 포스트 문서를 생성합니다.
    func uploadPhoto(_ image: UIImage,
                     forChallenge challengeId: String,
                     completion: @escaping (Result<Void,Error>) -> Void) {
        guard
            let uid = Auth.auth().currentUser?.uid
        else {
            completion(.failure(NSError(domain: "Upload",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "로그인이 필요합니다."])))
            return
        }
        
        // 1) 리사이즈 후 JPEG 변환
        let resized = image.resized(maxPixel: 1024)
        guard let data = resized.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "Upload",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "이미지 인코딩 실패"])))
            return
        }
        
        // 2) Storage 경로
        let fileName = UUID().uuidString + ".jpg"
        let storageRef = Storage.storage()
            .reference()
            .child("user_uploads/\(uid)/\(challengeId)/\(fileName)")
        
        // 3) 스토리지에 업로드
        storageRef.putData(data, metadata: nil) { [weak self] _, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            // 4) 다운로드 URL 받아오기
            storageRef.downloadURL { url, error in
                guard let downloadURL = url, error == nil else {
                    completion(.failure(error!))
                    return
                }
                
                // 5) Firestore에 challengePosts 문서 생성
                guard let self = self else { return }
                let postsRef = self.db.collection("challengePosts").document()
                let postId = postsRef.documentID
                let postData: [String: Any] = [
                    "userId":       uid,
                    "challengeId":  challengeId,
                    "imageUrl":     downloadURL.absoluteString,
                    "createdAt":    FieldValue.serverTimestamp(),
                    "reactions":    [String: Int](),   // 초기 반응 딕셔너리
                    "reported":     false
                ]
                
                postsRef.setData(postData) { err in
                    if let err = err {
                        completion(.failure(err))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }
}
