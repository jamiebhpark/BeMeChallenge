// Presentation/ViewModels/SponsoredChallengeViewModel.swift
import Foundation
import FirebaseFirestore

class SponsoredChallengeViewModel: ObservableObject {
    @Published var sponsoredChallenges: [SponsoredChallenge] = []
    private var db = Firestore.firestore()
    
    /// "sponsoredChallenges" 컬렉션에서 협찬 챌린지 데이터를 조회합니다.
    func fetchSponsoredChallenges() {
        db.collection("sponsoredChallenges")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching sponsored challenges: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                let challenges: [SponsoredChallenge] = documents.compactMap { doc in
                    try? doc.data(as: SponsoredChallenge.self)
                }
                DispatchQueue.main.async {
                    self.sponsoredChallenges = challenges
                }
            }
    }
}
