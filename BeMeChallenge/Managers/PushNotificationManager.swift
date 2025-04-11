// PushNotificationManager.swift
import Foundation
import UserNotifications
import FirebaseMessaging
import FirebaseAuth
import UIKit

class PushNotificationManager: NSObject, ObservableObject {
    static let shared = PushNotificationManager()
    
    /// 알림 권한 요청 및 원격 알림 등록
    func registerForPushNotifications() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        center.requestAuthorization(options: options) { granted, error in
            if let error = error {
                print("푸시 알림 권한 요청 에러: \(error.localizedDescription)")
                return
            }
            print("푸시 알림 권한 승인: \(granted)")
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        Messaging.messaging().delegate = self
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension PushNotificationManager: UNUserNotificationCenterDelegate {
    /// 앱이 포그라운드에 있을 때 알림 표시 옵션 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // 포그라운드일 때 배너, 사운드, 뱃지로 알림 표시
        completionHandler([.banner, .sound, .badge])
    }
    
    /// 알림 탭 등 사용자 상호작용 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("알림 응답: \(userInfo)")
        // 사용자 액션에 따른 내비게이션 등 추가 처리 가능
        completionHandler()
    }
}

// MARK: - MessagingDelegate
extension PushNotificationManager: MessagingDelegate {
    /// FCM 토큰이 업데이트될 때 호출됩니다.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        print("업데이트된 FCM 토큰: \(fcmToken)")
        
        // 예: 해당 토큰을 Firestore 또는 백엔드 서버에 저장하여 추후 푸시 알림 전송에 사용
        if let userId = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            db.collection("users").document(userId).setData(["fcmToken": fcmToken], merge: true) { error in
                if let error = error {
                    print("토큰 업데이트 에러: \(error.localizedDescription)")
                } else {
                    print("사용자 토큰 업데이트 성공")
                }
            }
        }
    }
}
