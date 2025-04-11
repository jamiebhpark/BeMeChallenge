// Presentation/ViewModels/NotificationViewModel.swift
import Foundation
import FirebaseFirestore
import FirebaseAuth

class NotificationViewModel: ObservableObject {
    @Published var notifications: [AppNotification] = []
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    /// 현재 사용자에 해당하는 알림 데이터를 실시간으로 가져옵니다.
    func fetchNotifications() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        listener?.remove()
        listener = db.collection("notifications")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("알림 조회 에러: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                let fetchedNotifications: [AppNotification] = documents.compactMap { doc in
                    do {
                        let notification = try doc.data(as: AppNotification.self)
                        return notification
                    } catch {
                        print("알림 디코딩 에러: \(error.localizedDescription)")
                        return nil
                    }
                }
                DispatchQueue.main.async {
                    self?.notifications = fetchedNotifications
                }
            }
    }
    
    deinit {
        listener?.remove()
    }
}
