// SettingsViewModel.swift (업데이트)
import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var nickname: String = ""
    @Published var profilePictureURL: String = ""
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    func fetchUserProfile() {
        guard let userId = userId else { return }
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { document, error in
            if let error = error {
                print("사용자 정보 가져오기 에러: \(error.localizedDescription)")
                return
            }
            if let data = document?.data() {
                DispatchQueue.main.async {
                    self.nickname = data["nickname"] as? String ?? "닉네임 없음"
                    self.profilePictureURL = data["profilePictureURL"] as? String ?? ""
                }
            }
        }
    }
    
    func updateNickname() {
        guard let userId = userId else { return }
        let userRef = db.collection("users").document(userId)
        userRef.updateData(["nickname": nickname]) { error in
            if let error = error {
                print("닉네임 업데이트 에러: \(error.localizedDescription)")
            } else {
                print("닉네임 업데이트 성공!")
            }
        }
    }
    
    func deleteAccount() {
        guard let userId = userId else { return }
        db.collection("users").document(userId).delete { error in
            if let error = error {
                print("계정 삭제 에러: \(error.localizedDescription)")
            } else {
                do {
                    try Auth.auth().signOut()
                    print("계정 삭제 및 로그아웃 성공")
                } catch {
                    print("로그아웃 에러: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            print("로그아웃 성공")
        } catch {
            print("로그아웃 에러: \(error.localizedDescription)")
        }
    }
    
    // 새로운 프로필 사진 업데이트 함수:
    func updateProfilePicture(newImage: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = userId else {
            completion(.failure(NSError(domain: "ProfileUpdate", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자를 찾을 수 없습니다."])))
            return
        }
        guard let imageData = newImage.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ProfileUpdate", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미지 변환 실패."])))
            return
        }
        let fileName = "profilePicture.jpg"
        let storageRef = storage.reference().child("profileImages/\(userId)/\(fileName)")
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
                    completion(.failure(NSError(domain: "ProfileUpdate", code: -1, userInfo: [NSLocalizedDescriptionKey: "다운로드 URL 생성 실패"])))
                    return
                }
                let userRef = self.db.collection("users").document(userId)
                userRef.updateData(["profilePictureURL": downloadURL.absoluteString]) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }
}
