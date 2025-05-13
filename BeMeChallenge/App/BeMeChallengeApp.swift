// BeMeChallengeApp.swift
import SwiftUI
import Firebase

@main
struct BeMeChallengeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var modalC = ModalCoordinator()

    var body: some Scene {
        WindowGroup {
            Group {
                if !authVM.isLoggedIn {
                    LoginViewWrapper()
                } else if !hasSeenOnboarding {
                    OnboardingViewWrapper()
                } else {
                    MainTabView()
                }
            }
            // 모든 화면에 AuthViewModel, ModalCoordinator 주입
            .environmentObject(authVM)
            .environmentObject(modalC)
            .onAppear { authVM.checkLoginStatus() }
        }
    }
}
