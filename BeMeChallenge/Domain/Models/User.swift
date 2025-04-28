// Domain/Models/User.swift
import Foundation
import FirebaseFirestore
import FirebaseAuth

public struct User: Identifiable, Codable {
    public let id: String
    public let nickname: String
    public let bio: String?
    public let location: String?
    public let profileImageURL: String?
    public let profileImageUpdatedAt: TimeInterval?
    public let isProfilePublic: Bool
    public let fcmToken: String?

    // 1) Firestore DocumentSnapshot → User
    public init?(document: DocumentSnapshot) {
        let data = document.data() ?? [:]
        guard
            let nickname = data["nickname"] as? String,
            let isPublic = data["isProfilePublic"] as? Bool
        else {
            return nil
        }
        self.id = document.documentID
        self.nickname = nickname
        self.bio = data["bio"] as? String
        self.location = data["location"] as? String
        self.profileImageURL = data["profileImageURL"] as? String
        // 새로 추가된 타임스탬프 필드
        if let ts = data["profileImageUpdatedAt"] as? Timestamp {
            self.profileImageUpdatedAt = ts.dateValue().timeIntervalSince1970
        } else {
            self.profileImageUpdatedAt = nil
        }
        self.isProfilePublic = isPublic
        self.fcmToken = data["fcmToken"] as? String
    }

    // 2) Firestore QueryDocumentSnapshot → User
    public init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard
            let nickname = data["nickname"] as? String,
            let isPublic = data["isProfilePublic"] as? Bool
        else {
            return nil
        }
        self.id = document.documentID
        self.nickname = nickname
        self.bio = data["bio"] as? String
        self.location = data["location"] as? String
        self.profileImageURL = data["profileImageURL"] as? String
        if let ts = data["profileImageUpdatedAt"] as? Timestamp {
            self.profileImageUpdatedAt = ts.dateValue().timeIntervalSince1970
        } else {
            self.profileImageUpdatedAt = nil
        }
        self.isProfilePublic = isPublic
        self.fcmToken = data["fcmToken"] as? String
    }

    // 3) 직접 생성용 멤버와이즈 이니셜라이저
    public init(
        id: String,
        nickname: String,
        bio: String?,
        location: String?,
        profileImageURL: String?,
        profileImageUpdatedAt: TimeInterval? = nil,
        isProfilePublic: Bool,
        fcmToken: String?
    ) {
        self.id = id
        self.nickname = nickname
        self.bio = bio
        self.location = location
        self.profileImageURL = profileImageURL
        self.profileImageUpdatedAt = profileImageUpdatedAt
        self.isProfilePublic = isProfilePublic
        self.fcmToken = fcmToken
    }

    /// 캐시 무시용 버전 쿼리까지 붙인 최종 URL
    public var effectiveProfileImageURL: URL? {
        guard let base = profileImageURL else { return nil }
        if let v = profileImageUpdatedAt {
            let sep = base.contains("?") ? "&" : "?"
            return URL(string: "\(base)\(sep)v=\(Int(v))")
        }
        return URL(string: base)
    }
}

// ⚠️ struct 바깥, 파일 최상단에 선언
extension User {
    /// FirebaseAuth.User → 도메인 User 변환
    init(from firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.nickname = firebaseUser.displayName ?? "User"
        self.bio = nil
        self.location = nil
        self.profileImageURL = firebaseUser.photoURL?.absoluteString
        self.profileImageUpdatedAt = nil
        self.isProfilePublic = true
        self.fcmToken = nil
    }
}
