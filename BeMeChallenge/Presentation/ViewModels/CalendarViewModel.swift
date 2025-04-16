//  CalendarViewModel.swift
import SwiftUI
import FirebaseFirestore

class CalendarViewModel: ObservableObject {
    @Published var participationDates: [Date] = []
    
    private let db = Firestore.firestore()
    
    /// 사용자 ID의 참여 기록을 Firestore에서 불러와 날짜 배열에 저장합니다.
    func fetchParticipation(userId: String) {
        db.collection("users").document(userId).collection("participations")
            .order(by: "date", descending: false)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching participation records: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else {
                    print("No participation documents found")
                    return
                }
                let dates: [Date] = documents.compactMap { doc in
                    if let timestamp = doc.data()["date"] as? Timestamp {
                        let date = timestamp.dateValue()
                        print("Participation date: \(date)")
                        return date
                    }
                    return nil
                }
                DispatchQueue.main.async {
                    self?.participationDates = dates
                    print("전체 참여 날짜: \(dates)")
                }
            }
    }
    
    /// 현재 달의 날짜 배열을 반환합니다.
    /// 배열에는 달의 시작 전 빈 셀 (nil)과 모든 날짜, 그리고 마지막 주의 남는 셀을 nil로 채워 7열 그리드에 맞춥니다.
    func monthDates() -> [Date?] {
        let calendar = Calendar.current
        let now = Date()
        guard let monthInterval = calendar.dateInterval(of: .month, for: now) else { return [] }
        
        var dates: [Date?] = []
        let firstDay = monthInterval.start
        // Calendar의 기본 설정에 따라 요일이 1(일요일) ~ 7(토요일)로 반환됩니다.
        let weekday = calendar.component(.weekday, from: firstDay)
        let leadingEmptyCells = weekday - 1  // 예: 일요일이면 0, 월요일이면 1, etc.
        for _ in 0..<leadingEmptyCells { dates.append(nil) }
        
        // 실제 달의 날짜를 추가합니다.
        var currentDate = firstDay
        while currentDate < monthInterval.end {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        // 마지막 행을 맞추기 위한 빈 셀 추가 (7개의 열에 맞추기)
        while dates.count % 7 != 0 {
            dates.append(nil)
        }
        return dates
    }
}
