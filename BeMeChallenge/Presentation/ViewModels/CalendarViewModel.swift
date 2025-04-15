//  CalendarViewModel.swift
import SwiftUI
import FirebaseFirestore

class CalendarViewModel: ObservableObject {
    @Published var participationDates: [Date] = []
    
    private let db = Firestore.firestore()
    
    /// 지정한 사용자 ID의 챌린지 참여 기록을 Firestore에서 불러옵니다.
    func fetchParticipation(userId: String) {
        db.collection("users").document(userId).collection("participations")
            .order(by: "date", descending: false)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching participation records: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                let dates: [Date] = documents.compactMap { doc in
                    if let timestamp = doc.data()["date"] as? Timestamp {
                        return timestamp.dateValue()
                    }
                    return nil
                }
                DispatchQueue.main.async {
                    self?.participationDates = dates
                }
            }
    }
    
    /// 현재 월의 모든 날짜를 계산하여 반환합니다.
    func currentMonthDates() -> [Date] {
        let calendar = Calendar.current
        let now = Date()
        guard let monthInterval = calendar.dateInterval(of: .month, for: now) else { return [] }
        var dates: [Date] = []
        var currentDate = monthInterval.start
        
        while currentDate < monthInterval.end {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        return dates
    }
}
