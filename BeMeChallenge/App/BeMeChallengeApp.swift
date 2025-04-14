// BeMeChallengeApp.swift
import SwiftUI
import Firebase

@main
struct BeMeChallengeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            AppCoordinator()  // ContentView() 대신 AppCoordinator()를 사용합니다.
        }
    }
}
