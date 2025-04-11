// ProfileViewModel.swift (업데이트)
import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class ProfileViewModel: ObservableObject {
    @Published var participationDates: [Date] = []
    
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchParticipationRecords()
        logCalendarView() // 조회 시 이벤트 로깅
    }
    
    func fetchParticipationRecords() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userId).collection("participations")
            .order(by: "date", descending: false)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching participation records: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                let dates: [Date] = documents.compactMap {
                    if let timestamp = $0.data()["date"] as? Timestamp {
                        return timestamp.dateValue()
                    }
                    return nil
                }
                DispatchQueue.main.async {
                    self?.participationDates = dates
                }
            }
    }
    
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
    
    /// 달력 조회 이벤트 로깅 (현재 월 정보 사용)
    func logCalendarView() {
        if let userId = Auth.auth().currentUser?.uid {
            let currentMonth = Calendar.current.component(.month, from: Date())
            AnalyticsManager.shared.logProfileCalendarView(userId: userId, dateRange: "2024-\(currentMonth)")
        }
    }
}
