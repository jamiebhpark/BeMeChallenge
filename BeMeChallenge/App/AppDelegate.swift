// AppDelegate.swift (동적 링크 처리 추가)
import UIKit
import Firebase
import FirebaseDynamicLinks

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        PushNotificationManager.shared.registerForPushNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // 동적 링크 처리: Universal Link를 통한 앱 실행
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let incomingURL = userActivity.webpageURL {
            print("Received URL: \(incomingURL.absoluteString)")
            let handled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { dynamicLink, error in
                if let error = error {
                    print("Dynamic Link 처리 오류: \(error.localizedDescription)")
                    return
                }
                if let challengeId = DynamicLinksManager.shared.handleDynamicLink(dynamicLink) {
                    // 챌린지 ID를 추출하여 해당 챌린지 상세 화면으로 내비게이션 처리
                    print("동적 링크로 전달된 챌린지 ID: \(challengeId)")
                    // 예를 들어, RootViewModel이나 Coordinator를 통해 ChallengeDetailView로 전환
                    // 이 부분은 앱의 내비게이션 구조에 맞게 구현합니다.
                }
            }
            return handled
        }
        return false
    }
}
