// Presentation/ViewModels/ProfileViewModel.swift

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import UIKit

@MainActor
final class ProfileViewModel: ObservableObject {
    // 프로필 로딩 상태
    @Published private(set) var profileState: Loadable<UserProfile> = .idle
    // 내 포스트 목록
    @Published var userPosts: [Post] = []
    
    private let db      = Firestore.firestore()
    private let storage = Storage.storage()
    private var listener: ListenerRegistration?
    
    private var uid: String? { Auth.auth().currentUser?.uid }
    
    init() {
        subscribeProfile()
        listenUserPosts()
    }
    deinit { listener?.remove() }
    
    /// 뷰가 appear 될 때 또는 재시도 버튼 눌렀을 때 호출
    func refresh() {
        subscribeProfile()
        listenUserPosts()
    }
    
    /// Firestore 에서 내 프로필 실시간 구독
    private func subscribeProfile() {
        guard let uid = uid else { return }
        profileState = .loading
        listener = db
            .collection("users")
            .document(uid)
            .addSnapshotListener { [weak self] snap, error in
                guard let self = self else { return }
                if let error = error {
                    self.profileState = .failed(error)
                    return
                }
                do {
                    let prof = try snap?.data(as: UserProfile.self)
                    self.profileState = .loaded(prof!)
                } catch {
                    self.profileState = .failed(error)
                }
            }
    }
    
    /// Firestore 에서 내 포스트 실시간 구독
    private func listenUserPosts() {
        guard let uid = uid else { return }
        db.collection("challengePosts")
          .whereField("userId", isEqualTo: uid)
          .order(by: "createdAt", descending: true)
          .addSnapshotListener { [weak self] snap, error in
              guard let self = self else { return }
              if error != nil { return }
              self.userPosts = snap?.documents.compactMap { doc in
                  try? doc.data(as: Post.self)
              } ?? []
          }
    }
    
    /// 프로필 정보 업데이트
    /// 성공 시에는 스냅샷 리스너가 자동으로 최신 프로필을 내려주므로
    /// 여기서는 단순히 Firestore 업데이트만 수행합니다.
    func updateProfile(
        nickname: String,
        bio: String?,
        location: String?
    ) async -> Result<Void, Error> {
        guard let uid = uid else {
            return .failure(NSError(
                domain: "Profile",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "로그인이 필요합니다"]
            ))
        }
        do {
            try await db
                .collection("users")
                .document(uid)
                .updateData([
                    "nickname": nickname,
                    "bio": bio as Any,
                    "location": location as Any
                ])
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    /// 프로필 사진 업로드
    func updateProfilePicture(
        _ image: UIImage,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let uid = uid else {
            completion(.failure(NSError(
                domain: "Profile",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "로그인이 필요합니다"]
            )))
            return
        }
        // 1) 리사이즈 + JPEG 압축
        let resized = image.resized(maxPixel: 1024)
        guard let data = resized.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(
                domain: "Profile",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "이미지 인코딩 실패"]
            )))
            return
        }
        // 2) 스토리지 업로드
        let ref = storage.reference().child("profile_images/\(uid).jpg")
        ref.putData(data, metadata: nil) { [weak self] _, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            ref.downloadURL { url, error in
                guard let dlURL = url, error == nil else {
                    completion(.failure(error!))
                    return
                }
                // 3) Firestore 업데이트 (serverTimestamp → Date로 디코딩)
                self?.db.collection("users").document(uid)
                    .updateData([
                        "profileImageURL":       dlURL.absoluteString,
                        "profileImageUpdatedAt": FieldValue.serverTimestamp()
                    ]) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
            }
        }
    }
    
    /// 기본 아바타로 되돌리기
    func resetProfilePicture() {
        guard let uid = uid else { return }
        db.collection("users").document(uid)
          .updateData([
              "profileImageURL":       FieldValue.delete(),
              "profileImageUpdatedAt": FieldValue.delete()
          ])
    }
    
    /// 포스트 삭제
    func deletePost(_ post: Post) {
        guard let id = post.id else { return }
        db.collection("challengePosts").document(id).delete()
    }
    
    /// 포스트 신고
    func reportPost(_ post: Post) {
        guard let id = post.id else { return }
        ReportService.shared.reportPost(postId: id) { _ in }
    }
}

/// Firestore 의 Timestamp 를 Swift Date 로 바로 디코딩합니다
struct UserProfile: Identifiable, Codable {
    @DocumentID var id: String?
    let nickname: String
    let bio: String?
    let location: String?
    let profileImageURL: String?
    let profileImageUpdatedAt: Date?
}
