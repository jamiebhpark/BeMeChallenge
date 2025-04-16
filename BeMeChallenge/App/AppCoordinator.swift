//AppCoordinator.swift
import SwiftUI
import Firebase

struct AppCoordinator: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @StateObject var authViewModel = AuthViewModel() // 공유할 AuthViewModel

    var body: some View {
        Group {
            if !authViewModel.isLoggedIn {
                LoginViewWrapper() // 공유된 authViewModel을 사용하도록 함
            } else if !hasSeenOnboarding {
                OnboardingViewWrapper()
            } else {
                MainTabView()
            }
        }
        .environmentObject(authViewModel) // 환경 객체로 전달
        .onAppear {
            authViewModel.checkLoginStatus()
        }
    }
}

struct OnboardingViewWrapper: View {
    var body: some View {
        OnboardingView()
            .onDisappear {
                // 온보딩 완료 시 플래그를 true로 저장 (계정 삭제나 로그아웃 시에 초기화됨)
                UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
            }
    }
}

struct LoginViewWrapper: View {
    @EnvironmentObject var authViewModel: AuthViewModel  // 환경 객체로 받아옴
    var body: some View {
        LoginView(authViewModel: authViewModel) // 이미 생성된 인스턴스를 전달
    }
}

struct AppCoordinator_Previews: PreviewProvider {
    static var previews: some View {
        AppCoordinator()
    }
}
