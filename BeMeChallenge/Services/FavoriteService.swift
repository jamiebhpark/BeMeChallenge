// FavoriteService.swift
import Foundation
import FirebaseFirestore
import FirebaseAuth

class FavoriteService {
    static let shared = FavoriteService()
    private let db = Firestore.firestore()
    
    /// 현재 사용자의 즐겨찾기 목록에 아이템 추가
    func addFavorite(itemId: String, type: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "FavoriteService", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자를 찾을 수 없습니다."])))
            return
        }
        let newFavorite: [String: Any] = [
            "itemId": itemId,
            "type": type,
            "createdAt": FieldValue.serverTimestamp()
        ]
        db.collection("users").document(userId).collection("favorites").addDocument(data: newFavorite) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    /// 현재 사용자의 즐겨찾기 목록에서 특정 아이템 제거
    func removeFavorite(itemId: String, type: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "FavoriteService", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자를 찾을 수 없습니다."])))
            return
        }
        let favoritesRef = db.collection("users").document(userId).collection("favorites")
        favoritesRef.whereField("itemId", isEqualTo: itemId)
            .whereField("type", isEqualTo: type)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let documents = snapshot?.documents else {
                    completion(.success(()))
                    return
                }
                let group = DispatchGroup()
                for doc in documents {
                    group.enter()
                    favoritesRef.document(doc.documentID).delete { error in
                        if let error = error {
                            print("즐겨찾기 삭제 에러: \(error.localizedDescription)")
                        }
                        group.leave()
                    }
                }
                group.notify(queue: .main) {
                    completion(.success(()))
                }
            }
    }
    
    /// 현재 사용자의 즐겨찾기 목록을 조회합니다.
    func fetchFavorites(completion: @escaping (Result<[Favorite], Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "FavoriteService", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자를 찾을 수 없습니다."])))
            return
        }
        db.collection("users").document(userId).collection("favorites")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                let favorites: [Favorite] = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Favorite.self)
                } ?? []
                completion(.success(favorites))
            }
    }
}
