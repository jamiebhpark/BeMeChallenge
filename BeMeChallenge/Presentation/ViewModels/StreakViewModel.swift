// StreakViewModel.swift
import Foundation
import FirebaseFirestore
import FirebaseAuth

class StreakViewModel: ObservableObject {
    @Published var currentStreak: Int = 0
    private let db = Firestore.firestore()
    
    /// 사용자의 참여 기록(날짜 목록)을 Firestore에서 가져옵니다.
    func fetchParticipationDates(completion: @escaping ([Date]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        db.collection("users").document(userId).collection("participations")
            .order(by: "date", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("참여 날짜 가져오기 에러: \(error.localizedDescription)")
                    completion([])
                    return
                }
                let dates = snapshot?.documents.compactMap { doc -> Date? in
                    if let timestamp = doc.data()["date"] as? Timestamp {
                        return timestamp.dateValue()
                    }
                    return nil
                } ?? []
                completion(dates)
            }
    }
    
    /// 참여 날짜 배열을 기반으로 연속 참여(스트릭) 일수를 계산합니다.
    func calculateStreak(from dates: [Date]) -> Int {
        let calendar = Calendar.current
        guard !dates.isEmpty else { return 0 }
        
        // 날짜를 오름차순으로 정렬
        let sortedDates = dates.sorted()
        var streak = 1
        // 가장 최근 참여 날짜를 시작점으로 설정
        var previousDate = sortedDates.last!
        
        // 가장 최근 날짜부터 뒤로 진행하며 연속성을 확인
        for date in sortedDates.reversed().dropFirst() {
            if let dayDifference = calendar.dateComponents([.day], from: date, to: previousDate).day {
                if dayDifference == 1 {
                    streak += 1
                    previousDate = date
                } else if dayDifference == 0 {
                    // 같은 날 여러 번 참여한 경우 중복 처리
                    continue
                } else {
                    break
                }
            }
        }
        return streak
    }
    
    /// Firestore에서 참여 날짜를 가져온 후 스트릭을 계산하여 업데이트합니다.
    func fetchAndCalculateStreak() {
        fetchParticipationDates { dates in
            DispatchQueue.main.async {
                self.currentStreak = self.calculateStreak(from: dates)
            }
        }
    }
}
