// ProfileViewModel.swift (업데이트)
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class ProfileViewModel: ObservableObject {
    @Published var nickname: String = "닉네임"
    @Published var profileImageURL: String? = nil
    @Published var joinDateString: String = "2024-01-01"
    @Published var bio: String = ""
    @Published var location: String = ""
    @Published var participationDates: [Date] = []
    @Published var calendarViewModel: CalendarViewModel = CalendarViewModel()
    
    // 오류 처리용 프로퍼티 추가
    @Published var errorMessage: String? = nil
    
    let db = Firestore.firestore()
    
    // 프로필 완성도 계산 (닉네임, 프로필 이미지, bio, 위치 4가지 기준)
    var completionPercentage: Double {
        let totalFields = 4.0
        var filled: Double = 0.0
        if !nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { filled += 1.0 }
        if let profileImageURL = profileImageURL, !profileImageURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { filled += 1.0 }
        if !bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { filled += 1.0 }
        if !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { filled += 1.0 }
        return (filled / totalFields) * 100.0
    }
    
    func fetchUserProfile() {
        guard let user = Auth.auth().currentUser else { return }
        let userDocRef = db.collection("users").document(user.uid)
        userDocRef.getDocument { snapshot, error in
            if let error = error {
                print("프로필 불러오기 실패: \(error.localizedDescription)")
                return
            }
            guard let data = snapshot?.data() else { return }
            DispatchQueue.main.async {
                self.nickname = data["nickname"] as? String ?? "닉네임"
                if let joinTimestamp = data["joinDate"] as? Timestamp {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    self.joinDateString = formatter.string(from: joinTimestamp.dateValue())
                }
                self.profileImageURL = data["profileImageURL"] as? String
                self.bio = data["bio"] as? String ?? ""
                self.location = data["location"] as? String ?? ""
            }
            self.calendarViewModel.fetchParticipation(userId: user.uid)
        }
    }
    
    func logCalendarView() {
        if let userId = Auth.auth().currentUser?.uid {
            let currentMonth = Calendar.current.component(.month, from: Date())
            AnalyticsManager.shared.logProfileCalendarView(userId: userId, dateRange: "2024-\(currentMonth)")
        }
    }
    
    func updateNickname(newNickname: String, completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false)
            return
        }
        let userDocRef = db.collection("users").document(user.uid)
        userDocRef.updateData(["nickname": newNickname]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("닉네임 업데이트 실패: \(error.localizedDescription)")
                    completion(false)
                } else {
                    self.nickname = newNickname
                    completion(true)
                }
            }
        }
    }
    
    func updateProfilePicture(newImage: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "ProfileViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자 정보를 찾을 수 없습니다."])))
            return
        }
        guard let imageData = newImage.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ProfileViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미지 변환에 실패했습니다."])))
            return
        }
        let storageRef = Storage.storage().reference().child("profile_images/\(user.uid).jpg")
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
                    completion(.failure(NSError(domain: "ProfileViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Download URL is nil."])))
                    return
                }
                let userDocRef = self.db.collection("users").document(user.uid)
                userDocRef.updateData(["profileImageURL": downloadURL.absoluteString]) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            self.profileImageURL = downloadURL.absoluteString
                            completion(.success(()))
                        }
                    }
                }
            }
        }
    }
    
    func updateAdditionalInfo(newBio: String, newLocation: String, completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false)
            return
        }
        let userDocRef = db.collection("users").document(user.uid)
        userDocRef.updateData([
            "bio": newBio,
            "location": newLocation
        ]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("추가 정보 업데이트 실패: \(error.localizedDescription)")
                    completion(false)
                } else {
                    self.bio = newBio
                    self.location = newLocation
                    completion(true)
                }
            }
        }
    }
}
