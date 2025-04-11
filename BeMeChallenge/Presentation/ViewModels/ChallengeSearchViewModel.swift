// ChallengeSearchViewModel.swift
import Foundation
import FirebaseFirestore
import Combine

class ChallengeSearchViewModel: ObservableObject {
    @Published var challenges: [Challenge] = []
    @Published var searchText: String = ""
    @Published var filteredChallenges: [Challenge] = []
    
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchChallenges()
        // 검색어 변화가 있을 때, 일정 시간 지연 후 필터링(디바운스)
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.filterChallenges(text: text)
            }
            .store(in: &cancellables)
    }
    
    /// Firestore에서 챌린지 데이터를 가져옵니다.
    func fetchChallenges() {
        db.collection("challenges")
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("챌린지 조회 에러: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                let challenges: [Challenge] = documents.compactMap { doc in
                    let data = doc.data()
                    guard let title = data["title"] as? String,
                          let description = data["description"] as? String,
                          let participantsCount = data["participantsCount"] as? Int,
                          let endTimestamp = data["endDate"] as? Timestamp
                    else { return nil }
                    let endDate = endTimestamp.dateValue()
                    return Challenge(
                        id: doc.documentID,
                        title: title,
                        description: description,
                        participantsCount: participantsCount,
                        endDate: endDate
                    )
                }
                DispatchQueue.main.async {
                    self?.challenges = challenges
                    self?.filterChallenges(text: self?.searchText ?? "")
                }
            }
    }
    
    /// 검색어를 바탕으로 챌린지 목록을 필터링합니다.
    private func filterChallenges(text: String) {
        if text.isEmpty {
            filteredChallenges = challenges
        } else {
            let lowercasedText = text.lowercased()
            filteredChallenges = challenges.filter { challenge in
                challenge.title.lowercased().contains(lowercasedText)
            }
        }
    }
}
