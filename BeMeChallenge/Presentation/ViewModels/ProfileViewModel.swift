// ProfileViewModel.swift (업데이트)
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class ProfileViewModel: ObservableObject {
    // MARK: — Published Properties
    @Published var nickname: String = ""
    @Published var profileImageURL: String? = nil
    @Published var bio: String = ""
    @Published var location: String = ""
    @Published var errorMessage: String? = nil
    
    // 캘린더 전용 뷰모델로 참여 기록 관리
    @Published var calendarViewModel = CalendarViewModel()
    
    private let db = Firestore.firestore()
    
    /// 프로필 완성도: nickname, profileImageURL, bio, location 네 가지 기준
    var completionPercentage: Double {
        let values = [
            nickname.trimmingCharacters(in: .whitespacesAndNewlines),
            (profileImageURL ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            bio.trimmingCharacters(in: .whitespacesAndNewlines),
            location.trimmingCharacters(in: .whitespacesAndNewlines)
        ]
        let filledCount = values.filter { !$0.isEmpty }.count
        return Double(filledCount) / Double(values.count) * 100
    }
    
    /// Firestore에서 사용자 프로필 데이터와 참여 기록을 함께 불러옵니다.
    func fetchUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = db.collection("users").document(uid)
        ref.getDocument { snapshot, error in
            if let error = error {
                DispatchQueue.main.async { self.errorMessage = error.localizedDescription }
                return
            }
            guard let data = snapshot?.data() else { return }
            DispatchQueue.main.async {
                self.nickname = data["nickname"] as? String ?? ""
                self.profileImageURL = data["profileImageURL"] as? String
                self.bio = data["bio"] as? String ?? ""
                self.location = data["location"] as? String ?? ""
            }
            self.calendarViewModel.fetchParticipation(userId: uid)
        }
    }
    
    /// 닉네임만 업데이트
    func updateNickname(to newName: String, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return completion(false) }
        let ref = db.collection("users").document(uid)
        ref.updateData(["nickname": newName]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    self.nickname = newName
                    completion(true)
                }
            }
        }
    }
    
    /// bio·location 업데이트
    func updateAdditionalInfo(bio: String, location: String, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return completion(false) }
        let ref = db.collection("users").document(uid)
        ref.updateData([
            "bio": bio,
            "location": location
        ]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    self.bio = bio
                    self.location = location
                    completion(true)
                }
            }
        }
    }
    
    /// 프로필 사진만 업데이트
    func updateProfilePicture(_ image: UIImage, completion: @escaping (Result<Void,Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid,
              let data = image.jpegData(compressionQuality: 0.8)
        else {
            return completion(.failure(NSError(domain:"", code:-1, userInfo:nil)))
        }
        let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")
        storageRef.putData(data, metadata: StorageMetadata()) { _, error in
            if let error = error { return completion(.failure(error)) }
            storageRef.downloadURL { url, error in
                if let error = error { return completion(.failure(error)) }
                guard let url = url else { return completion(.failure(NSError(domain:"",code:-1,userInfo:nil))) }
                self.db.collection("users").document(uid).updateData([
                    "profileImageURL": url.absoluteString
                ]) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            self.profileImageURL = url.absoluteString
                            completion(.success(()))
                        }
                    }
                }
            }
        }
    }
}
