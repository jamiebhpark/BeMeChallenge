import SwiftUI
import Firebase

struct AppCoordinator: View {
    // 온보딩 완료 플래그: UserDefaults를 활용(최신 iOS에서는 @AppStorage 사용)
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @StateObject var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if !authViewModel.isLoggedIn {
                // 로그인 화면: 사용자가 소셜 로그인으로 접근하도록 유도
                LoginViewWrapper() // UIKit 래퍼 등을 통해 UIViewController 제공 가능
            } else if !hasSeenOnboarding {
                // 온보딩 완료 전: 온보딩 화면을 보여주고 완료 시 플래그를 업데이트
                OnboardingViewWrapper()
            } else {
                // 모든 조건 충족 시: 메인 앱 화면 (메인 탭 뷰를 포함한 전체 기능)
                MainTabView()
            }
        }
        .onAppear {
            authViewModel.checkLoginStatus()
        }
    }
}

// 온보딩 화면 UIKit 래퍼 (온보딩이 완료되면, UserDefaults에 완료 플래그 저장)
struct OnboardingViewWrapper: View {
    var body: some View {
        OnboardingView()
            .onDisappear {
                // 온보딩 완료 후 플래그 업데이트(실제로는 사용자가 "시작하기" 버튼을 누른 시점에 처리)
                UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
            }
    }
}

// 로그인 화면 UIKit 래퍼: 필요 시 UIViewControllerRepresentable을 사용하여 UIKit 기반 로그인 화면을 제공
struct LoginViewWrapper: View {
    var body: some View {
        // 단순 예제에서는 SwiftUI 기반 LoginView를 그대로 사용
        LoginView()
    }
}

struct AppCoordinator_Previews: PreviewProvider {
    static var previews: some View {
        // Firebase를 초기화한 상태여야 하므로, 실제 디바이스나 시뮬레이터에서 확인 필요
        AppCoordinator()
    }
}
