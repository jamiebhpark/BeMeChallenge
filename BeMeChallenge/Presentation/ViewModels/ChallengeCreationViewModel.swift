// ChallengeCreationViewModel.swift
import Foundation
import FirebaseFirestore
import Combine

class ChallengeCreationViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var type: String = "필수" // 기본값: "필수"
    @Published var endDate: Date = Date()
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    /// 새 챌린지를 생성하여 Firestore에 저장합니다.
    func createChallenge(completion: @escaping (Bool) -> Void) {
        guard !title.isEmpty, !description.isEmpty else {
            self.errorMessage = "제목과 설명을 모두 입력해주세요."
            completion(false)
            return
        }
        
        let newChallenge: [String: Any] = [
            "title": title,
            "description": description,
            "type": type,
            "participantsCount": 0,
            "endDate": endDate,
            "createdAt": FieldValue.serverTimestamp(),
            "isActive": true
        ]
        
        db.collection("challenges").addDocument(data: newChallenge) { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
            } else {
                // 챌린지 생성 이벤트 로깅
                AnalyticsManager.shared.logEvent("challenge_created", parameters: [
                    "title": self.title,
                    "type": self.type
                ])
                completion(true)
            }
        }
    }
}
