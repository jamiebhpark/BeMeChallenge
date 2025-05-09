// Presentation/ViewModels/ProfileViewModel.swift
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import UIKit

@MainActor
final class ProfileViewModel: ObservableObject {
    // MARK: - Published
    @Published var nickname: String = ""
    @Published var profileImageURL: String?
    @Published var profileImageUpdatedAt: TimeInterval?
    @Published var bio: String = ""
    @Published var location: String = ""
    @Published var errorMessage: String?
    @Published var isUpdating: Bool = false

    @Published var participationDates: [Date] = []
    @Published var currentStreak: Int = 0
    @Published var totalParticipations: Int = 0

    // **내 포스트 목록**
    @Published var userPosts: [Post] = []

    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var listener: ListenerRegistration?

    private var uid: String? { Auth.auth().currentUser?.uid }

    init() {
        subscribeUser()
        loadParticipationStats()
        listenUserPosts()      // ← 여기에 호출
    }

    deinit {
        listener?.remove()
    }

    /// Firestore 실시간 구독: 사용자 프로필 정보
    private func subscribeUser() {
        guard let uid = uid else { return }
        listener = db.collection("users")
            .document(uid)
            .addSnapshotListener { [weak self] snap, _ in
                guard let data = snap?.data(), let self = self else { return }
                DispatchQueue.main.async {
                    self.nickname = data["nickname"] as? String ?? ""
                    self.profileImageURL = data["profileImageURL"] as? String
                    if let ts = data["profileImageUpdatedAt"] as? Timestamp {
                        self.profileImageUpdatedAt = ts.dateValue().timeIntervalSince1970
                    }
                    self.bio      = data["bio"] as? String ?? ""
                    self.location = data["location"] as? String ?? ""
                }
            }
    }

    /// 참여 통계 로드
    private func loadParticipationStats() {
        guard let uid = uid else { return }
        db.collection("challengePosts")
            .whereField("userId", isEqualTo: uid)
            .order(by: "createdAt", descending: false)
            .getDocuments { [weak self] snap, error in
                guard let self = self else { return }
                if let error = error {
                    print("참여 기록 로딩 오류:", error.localizedDescription)
                    return
                }
                let dates = snap?.documents.compactMap {
                    ($0.data()["createdAt"] as? Timestamp)?.dateValue()
                } ?? []
                DispatchQueue.main.async {
                    self.participationDates = dates
                    self.computeStats()
                }
            }
    }

    private func listenUserPosts() {
        guard let uid = uid else { return }
        db.collection("challengePosts")
          .whereField("userId", isEqualTo: uid)
          .order(by: "createdAt", descending: true)
          .addSnapshotListener { [weak self] snap, _ in
              guard let docs = snap?.documentChanges, let self = self else { return }

              // 변동된 포스트만 반영 (컴파일과는 무관하지만 성능 최적)
              for change in docs {
                  let data = change.document.data()
                  guard
                      let challengeId = data["challengeId"] as? String,
                      let imageUrl    = data["imageUrl"]    as? String
                  else { continue }

                  let post = Post(
                      id: change.document.documentID,
                      challengeId: challengeId,
                      userId:      uid,
                      imageUrl:    imageUrl,
                      createdAt:   (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                      reactions:   data["reactions"] as? [String: Int] ?? [:],
                      reported:    data["reported"] as? Bool ?? false,
                      caption:     data["caption"]  as? String
                  )

                  DispatchQueue.main.async {
                      switch change.type {
                      case .added:
                          self.userPosts.insert(post, at: 0)
                      case .modified:
                          if let idx = self.userPosts.firstIndex(where: { $0.id == post.id }) {
                              self.userPosts[idx] = post
                          }
                      case .removed:
                          self.userPosts.removeAll { $0.id == post.id }
                      }
                  }
              }
          }
    }


    /// 참여 통계 계산
    private func computeStats() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // 총 참여
        totalParticipations = participationDates.count

        // 연속 참여(streak)
        var streak = 0
        var check = today
        while participationDates.contains(where: { calendar.isDate($0, inSameDayAs: check) }) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: check) else { break }
            check = prev
        }
        currentStreak = streak
    }
    
    // MARK: - 닉네임 업데이트
    func updateNickname(to newName: String,
                        completion: @escaping (Bool) -> Void) {
        guard let uid = uid else {
            completion(false); return
        }
        isUpdating = true
        db.collection("users").document(uid)
          .updateData(["nickname": newName]) { [weak self] err in
              DispatchQueue.main.async {
                  self?.isUpdating = false
                  if let err = err {
                      self?.errorMessage = err.localizedDescription
                      completion(false)
                  } else {
                      self?.nickname = newName
                      completion(true)
                  }
              }
          }
    }

    // MARK: - Bio & Location 업데이트
    func updateAdditionalInfo(bio: String,
                              location: String,
                              completion: @escaping (Bool) -> Void) {
        guard let uid = uid else {
            completion(false); return
        }
        isUpdating = true
        db.collection("users").document(uid)
          .updateData([
              "bio": bio,
              "location": location
          ]) { [weak self] err in
              DispatchQueue.main.async {
                  self?.isUpdating = false
                  if let err = err {
                      self?.errorMessage = err.localizedDescription
                      completion(false)
                  } else {
                      self?.bio = bio
                      self?.location = location
                      completion(true)
                  }
              }
          }
    }

    // MARK: - 프로필 사진 업데이트 (리사이즈 + 버전 타임스탬프)
    func updateProfilePicture(_ image: UIImage,
                              completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = uid else {
            completion(.failure(NSError(
                domain: "ProfileUpdate",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "사용자 없음"]
            )))
            return
        }
        isUpdating = true

        // 1) 리사이즈
        let resized = image.resized(maxPixel: 1024)
        guard let data = resized.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(
                domain: "ProfileUpdate",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "이미지 인코딩 실패"]
            )))
            return
        }

        // 2) 스토리지 업로드
        let ref = storage.reference().child("profile_images/\(uid).jpg")
        ref.putData(data, metadata: nil) { [weak self] _, error in
            guard error == nil else {
                DispatchQueue.main.async { self?.isUpdating = false }
                completion(.failure(error!)); return
            }

            // 3) 다운로드 URL & Firestore 업데이트
            ref.downloadURL { url, error in
                DispatchQueue.main.async { self?.isUpdating = false }
                guard let dlURL = url, error == nil else {
                    completion(.failure(error!)); return
                }
                self?.db.collection("users").document(uid)
                    .updateData([
                        "profileImageURL": dlURL.absoluteString,
                        "profileImageUpdatedAt": FieldValue.serverTimestamp()
                    ]) { err in
                        DispatchQueue.main.async {
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
    
    func resetProfilePicture() {
      guard let uid = Auth.auth().currentUser?.uid else { return }
      db.collection("users").document(uid)
        .updateData([
          "profileImageURL": FieldValue.delete(),
          "profileImageUpdatedAt": FieldValue.delete()
        ])
    }
}
