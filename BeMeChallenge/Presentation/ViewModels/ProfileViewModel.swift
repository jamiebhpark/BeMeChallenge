// ProfileViewModel.swift (업데이트)
import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class ProfileViewModel: ObservableObject {
    @Published var nickname: String = "닉네임"
    @Published var profileImageURL: String? = nil
    @Published var joinDateString: String = "2024-01-01"
    
    // CalendarViewModel을 별도 프로퍼티로 관리합니다.
    @Published var calendarViewModel: CalendarViewModel = CalendarViewModel()
    
    private let db = Firestore.firestore()
    
    /// 사용자 프로필 정보와 함께 달력 참여 기록을 불러옵니다.
    func fetchUserProfile() {
        guard let user = Auth.auth().currentUser else { return }
        let userDocRef = db.collection("users").document(user.uid)
        userDocRef.getDocument { snapshot, error in
            if let error = error {
                print("프로필 불러오기 실패: \(error.localizedDescription)")
                return
            }
            guard let data = snapshot?.data() else { return }
            DispatchQueue.main.async {
                self.nickname = data["nickname"] as? String ?? "닉네임"
                if let joinTimestamp = data["joinDate"] as? Timestamp {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    self.joinDateString = formatter.string(from: joinTimestamp.dateValue())
                }
                self.profileImageURL = data["profileImageURL"] as? String
            }
            // 달력 참여 기록 불러오기
            self.calendarViewModel.fetchParticipation(userId: user.uid)
        }
    }
    
    /// 달력 조회 이벤트 로깅 (예시)
    func logCalendarView() {
        if let userId = Auth.auth().currentUser?.uid {
            let currentMonth = Calendar.current.component(.month, from: Date())
            AnalyticsManager.shared.logProfileCalendarView(userId: userId, dateRange: "2024-\(currentMonth)")
        }
    }
}
