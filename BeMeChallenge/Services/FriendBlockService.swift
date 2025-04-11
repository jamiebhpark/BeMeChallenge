// FriendBlockService.swift
import Foundation
import FirebaseFirestore
import FirebaseAuth

class FriendBlockService {
    static let shared = FriendBlockService()
    private let db = Firestore.firestore()
    
    /// 현재 사용자(document)에 userId를 차단 목록에 추가합니다.
    func blockUser(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "FriendBlockService", code: -1, userInfo: [NSLocalizedDescriptionKey: "현재 사용자를 찾을 수 없습니다."])))
            return
        }
        let userRef = db.collection("users").document(currentUserId)
        userRef.updateData([
            "blockedUsers": FieldValue.arrayUnion([userId])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// 현재 사용자의 차단 목록에서 userId를 제거합니다.
    func unblockUser(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "FriendBlockService", code: -1, userInfo: [NSLocalizedDescriptionKey: "현재 사용자를 찾을 수 없습니다."])))
            return
        }
        let userRef = db.collection("users").document(currentUserId)
        userRef.updateData([
            "blockedUsers": FieldValue.arrayRemove([userId])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// 현재 사용자의 차단된 사용자 목록을 불러옵니다.
    func fetchBlockedUsers(completion: @escaping (Result<[BlockedUser], Error>) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "FriendBlockService", code: -1, userInfo: [NSLocalizedDescriptionKey: "현재 사용자를 찾을 수 없습니다."])))
            return
        }
        let userRef = db.collection("users").document(currentUserId)
        userRef.getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = snapshot?.data(),
                  let blockedUserIds = data["blockedUsers"] as? [String] else {
                completion(.success([]))
                return
            }
            var blockedUsers: [BlockedUser] = []
            let group = DispatchGroup()
            for userId in blockedUserIds {
                group.enter()
                self.db.collection("users").document(userId).getDocument { doc, error in
                    defer { group.leave() }
                    if let data = doc?.data(), let nickname = data["nickname"] as? String {
                        let profilePictureURL = data["profilePictureURL"] as? String
                        let blockedUser = BlockedUser(id: doc?.documentID, userId: userId, nickname: nickname, profilePictureURL: profilePictureURL)
                        blockedUsers.append(blockedUser)
                    }
                }
            }
            group.notify(queue: .main) {
                completion(.success(blockedUsers))
            }
        }
    }
}
