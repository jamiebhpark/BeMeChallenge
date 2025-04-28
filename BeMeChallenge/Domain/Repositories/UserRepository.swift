// Domain/Repositories/UserRepository.swift
import Foundation
import FirebaseFirestore

public protocol UserRepositoryProtocol {
    /// 단일 유저 조회
    func fetchUser(withId id: String,
                   completion: @escaping (Result<User, Error>) -> Void)
    /// 복수 유저 조회
    func fetchUsers(withIds ids: [String],
                    completion: @escaping (Result<[User], Error>) -> Void)
}

public final class UserRepository: UserRepositoryProtocol {
    private let db = Firestore.firestore()

    public init() {}

    public func fetchUser(withId id: String,
                          completion: @escaping (Result<User, Error>) -> Void) {
        db.collection("users").document(id).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let snapshot = snapshot,
                  snapshot.exists,
                  let user = User(document: snapshot)
            else {
                let err = NSError(domain: "UserRepository", code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "사용자 정보를 불러올 수 없습니다."])
                completion(.failure(err))
                return
            }
            completion(.success(user))
        }
    }

    public func fetchUsers(withIds ids: [String],
                           completion: @escaping (Result<[User], Error>) -> Void) {
        guard !ids.isEmpty else {
            completion(.success([]))
            return
        }
        db.collection("users")
          .whereField(FieldPath.documentID(), in: ids)
          .getDocuments { snapshot, error in
              if let error = error {
                  completion(.failure(error))
                  return
              }
              let users = snapshot?.documents.compactMap { User(document: $0) } ?? []
              completion(.success(users))
        }
    }
}
