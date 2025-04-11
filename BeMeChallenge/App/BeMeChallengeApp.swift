// BeMeChallengeApp.swift
import SwiftUI
import Firebase

@main
struct BeMeChallengeApp: App {
    // AppDelegate를 통해 Firebase 초기화
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView() // 로그인 상태에 따라 화면 전환
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()  // Firebase 초기화
        return true
    }
}
