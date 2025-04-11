// ProfileCompletionViewModel.swift
import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class ProfileCompletionViewModel: ObservableObject {
    @Published var completionPercentage: Double = 0.0
    @Published var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    
    /// 사용자의 프로필 도큐먼트에서 필수 항목의 입력 여부를 확인하고, 완료도를 계산합니다.
    func fetchUserProfileCompletion() {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "사용자 정보를 찾을 수 없습니다."
            return
        }
        
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { [weak self] snapshot, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            guard let data = snapshot?.data() else {
                DispatchQueue.main.async {
                    self?.completionPercentage = 0.0
                }
                return
            }
            
            // 필수 항목 목록 (추후 필요한 항목이 있으면 여기서 추가)
            let requiredFields = ["nickname", "profilePictureURL", "bio", "location"]
            
            // 입력된 필드 개수 계산
            let filledCount = requiredFields.filter { field in
                if let value = data[field] as? String, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    return true
                }
                return false
            }.count
            
            let percentage = (Double(filledCount) / Double(requiredFields.count)) * 100
            DispatchQueue.main.async {
                self?.completionPercentage = percentage
            }
        }
    }
}
