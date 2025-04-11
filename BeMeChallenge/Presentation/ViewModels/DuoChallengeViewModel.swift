// Presentation/ViewModels/DuoChallengeViewModel.swift
import Foundation
import FirebaseFirestore
import FirebaseAuth

class DuoChallengeViewModel: ObservableObject {
    @Published var duoChallenge: DuoChallenge?
    @Published var inviteCode: String = ""
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    /// 듀오 챌린지를 생성합니다.
    /// 현재 사용자가 주어진 챌린지에 대해 듀오 챌린지를 생성하고, 생성된 Document의 ID를 초대 코드로 반환합니다.
    func createDuoChallenge(for challengeId: String, completion: @escaping (Bool) -> Void) {
        guard let uid = userId else {
            self.errorMessage = "사용자 정보를 찾을 수 없습니다."
            completion(false)
            return
        }
        
        let newDuoChallenge: [String: Any] = [
            "challengeId": challengeId,
            "creatorId": uid,
            "partnerId": "",
            "status": "pending",   // 초기 상태: pending
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        var ref: DocumentReference? = nil
        ref = db.collection("duoChallenges").addDocument(data: newDuoChallenge) { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
            } else {
                if let documentId = ref?.documentID {
                    DispatchQueue.main.async {
                        self.inviteCode = documentId
                        completion(true)
                    }
                } else {
                    self.errorMessage = "초대 코드 생성에 실패했습니다."
                    completion(false)
                }
            }
        }
    }
    
    /// 친구가 초대 코드를 통해 듀오 챌린지에 참여합니다.
    func joinDuoChallenge(withCode code: String, completion: @escaping (Bool) -> Void) {
        guard let uid = userId else {
            self.errorMessage = "사용자 정보를 찾을 수 없습니다."
            completion(false)
            return
        }
        let duoRef = db.collection("duoChallenges").document(code)
        duoRef.getDocument { document, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            guard let data = document?.data(),
                  let creatorId = data["creatorId"] as? String,
                  creatorId != uid else {
                self.errorMessage = "자신이 생성한 챌린지에는 참여할 수 없습니다."
                completion(false)
                return
            }
            duoRef.updateData([
                "partnerId": uid,
                "status": "active"
            ]) { error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    /// 특정 듀오 챌린지 도큐먼트를 조회합니다.
    func fetchDuoChallenge(withCode code: String) {
        let duoRef = db.collection("duoChallenges").document(code)
        duoRef.getDocument { [weak self] document, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }
            guard let duo = try? document?.data(as: DuoChallenge.self) else { return }
            DispatchQueue.main.async {
                self?.duoChallenge = duo
            }
        }
    }
}
