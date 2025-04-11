// ProfilePrivacyViewModel.swift
import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

class ProfilePrivacyViewModel: ObservableObject {
    @Published var isProfilePublic: Bool = true
    @Published var errorMessage: String? = nil
    
    private let db = Firestore.firestore()
    
    /// 현재 사용자의 프로필 공개 여부를 Firestore에서 조회합니다.
    func fetchPrivacySetting() {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "사용자 정보를 찾을 수 없습니다."
            return
        }
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
                return
            }
            if let data = snapshot?.data() {
                DispatchQueue.main.async {
                    self?.isProfilePublic = data["isProfilePublic"] as? Bool ?? true
                }
            }
        }
    }
    
    /// 사용자로부터 전달받은 공개 여부(newValue)를 Firestore에 업데이트합니다.
    func updatePrivacySetting(to newValue: Bool, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "사용자 정보를 찾을 수 없습니다."
            completion(false)
            return
        }
        db.collection("users").document(userId).updateData([
            "isProfilePublic": newValue
        ]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
}
