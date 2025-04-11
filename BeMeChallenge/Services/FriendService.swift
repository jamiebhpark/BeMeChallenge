// FriendService.swift
import Foundation
import FirebaseFirestore
import FirebaseAuth

class FriendService {
    static let shared = FriendService()
    private let db = Firestore.firestore()
    
    /// 닉네임을 기준으로 친구 검색 (대소문자 구분없이 검색)
    func searchFriends(byNickname nickname: String, completion: @escaping (Result<[Friend], Error>) -> Void) {
        db.collection("users")
            .whereField("nickname", isGreaterThanOrEqualTo: nickname)
            .whereField("nickname", isLessThanOrEqualTo: nickname + "\u{f8ff}")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                let friends: [Friend] = snapshot?.documents.compactMap { doc in
                    let data = doc.data()
                    guard let nickname = data["nickname"] as? String else { return nil }
                    let profilePictureURL = data["profilePictureURL"] as? String
                    return Friend(id: doc.documentID, nickname: nickname, userId: doc.documentID, profilePictureURL: profilePictureURL)
                } ?? []
                completion(.success(friends))
            }
    }
    
    /// 친구 요청 전송
    /// 이 예제에서는 별도의 "friendRequests" 컬렉션을 사용합니다.
    func sendFriendRequest(to friendUserId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "FriendService", code: -1, userInfo: [NSLocalizedDescriptionKey: "현재 사용자를 찾을 수 없습니다."])))
            return
        }
        let requestData: [String: Any] = [
            "fromUserId": currentUserId,
            "toUserId": friendUserId,
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp()
        ]
        db.collection("friendRequests").addDocument(data: requestData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// 친구 목록 조회 (사용자의 document에 "friends" 배열 필드가 있다고 가정)
    func fetchFriendList(completion: @escaping (Result<[Friend], Error>) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "FriendService", code: -1, userInfo: [NSLocalizedDescriptionKey: "현재 사용자를 찾을 수 없습니다."])))
            return
        }
        db.collection("users").document(currentUserId).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = document?.data(), let friendIds = data["friends"] as? [String] else {
                completion(.success([]))
                return
            }
            var friends: [Friend] = []
            let group = DispatchGroup()
            for friendId in friendIds {
                group.enter()
                self.db.collection("users").document(friendId).getDocument { friendDoc, error in
                    defer { group.leave() }
                    if let data = friendDoc?.data(), let nickname = data["nickname"] as? String {
                        let profilePictureURL = data["profilePictureURL"] as? String
                        let friend = Friend(id: friendId, nickname: nickname, userId: friendId, profilePictureURL: profilePictureURL)
                        friends.append(friend)
                    }
                }
            }
            group.notify(queue: .main) {
                completion(.success(friends))
            }
        }
    }
}
