// ProfileViewModel.swift
// BeMeChallenge

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import UIKit  // for image resizing extension

@MainActor
final class ProfileViewModel: ObservableObject {
    // Published
    @Published var nickname: String = ""
    @Published var profileImageURL: String?
    @Published var profileImageUpdatedAt: TimeInterval?
    @Published var bio: String = ""
    @Published var location: String = ""
    @Published var errorMessage: String?
    @Published var isUpdating: Bool = false
    @Published var calendarViewModel = CalendarViewModel()

    private let db      = Firestore.firestore()
    private let storage = Storage.storage()
    private var listener: ListenerRegistration?

    private var uid: String? { Auth.auth().currentUser?.uid }

    init() {
        subscribeUser()
    }

    deinit {
        listener?.remove()
    }

    private func subscribeUser() {
        guard let uid = uid else { return }
        listener = db.collection("users")
            .document(uid)
            .addSnapshotListener { [weak self] snap, err in
                guard let self = self, let data = snap?.data() else { return }
                DispatchQueue.main.async {
                    self.nickname = data["nickname"] as? String ?? ""
                    self.profileImageURL = data["profileImageURL"] as? String
                    if let ts = data["profileImageUpdatedAt"] as? Timestamp {
                        self.profileImageUpdatedAt = ts.dateValue().timeIntervalSince1970
                    }
                    self.bio      = data["bio"] as? String ?? ""
                    self.location = data["location"] as? String ?? ""
                    if let tsArr = data["participationDates"] as? [Timestamp] {
                        self.calendarViewModel.participationDates = tsArr.map { $0.dateValue() }
                    }
                }
            }
    }

    // MARK: - 닉네임 업데이트
    func updateNickname(to newName: String,
                        completion: @escaping (Bool) -> Void) {
        guard let uid = uid else {
            completion(false); return
        }
        isUpdating = true
        db.collection("users")
          .document(uid)
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
        db.collection("users")
          .document(uid)
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
                      self?.bio      = bio
                      self?.location = location
                      completion(true)
                  }
              }
          }
    }

    // MARK: - 프로필 사진 업데이트 (리사이즈 + 버전 관리)
    func updateProfilePicture(_ image: UIImage,
                              completion: @escaping (Result<Void,Error>) -> Void) {
        guard let uid = uid else {
            completion(.failure(NSError(domain: "ProfileUpdate",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "사용자 없음"])))
            return
        }
        isUpdating = true

        // 1) 리사이즈
        let resized = image.resized(maxPixel: 1024)
        guard let data = resized.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ProfileUpdate",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "이미지 인코딩 실패"])))
            return
        }

        // 2) 업로드
        let ref = storage.reference().child("profile_images/\(uid).jpg")
        ref.putData(data, metadata: nil) { [weak self] _, error in
            guard error == nil else {
                DispatchQueue.main.async { self?.isUpdating = false }
                completion(.failure(error!)); return
            }
            // 3) 다운로드 URL + Firestore 갱신
            ref.downloadURL { url, error in
                DispatchQueue.main.async { self?.isUpdating = false }
                guard let dlURL = url, error == nil else {
                    completion(.failure(error!)); return
                }
                self?.db.collection("users")
                    .document(uid)
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
}
