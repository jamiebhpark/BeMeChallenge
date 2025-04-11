// AuthViewModel.swift
import SwiftUI
import FirebaseAuth
import Combine

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    
    // Google 로그인 호출 예시
    func loginWithGoogle(using presentingVC: UIViewController) {
        AuthService.shared.signInWithGoogle(presenting: presentingVC) { result in
            switch result {
            case .success(let user):
                // 로그인 성공 이벤트 로깅
                AnalyticsManager.shared.logUserLogin(method: "google", success: true)
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                }
            case .failure(let error):
                // 로그인 실패 이벤트 로깅
                AnalyticsManager.shared.logUserLogin(method: "google", success: false)
                print("Google 로그인 실패: \(error.localizedDescription)")
            }
        }
    }
    
    // Apple 로그인 호출 예시
    func loginWithApple(using credential: ASAuthorizationAppleIDCredential) {
        AuthService.shared.signInWithApple(credential: credential) { result in
            switch result {
            case .success(let user):
                AnalyticsManager.shared.logUserLogin(method: "apple", success: true)
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                }
            case .failure(let error):
                AnalyticsManager.shared.logUserLogin(method: "apple", success: false)
                print("Apple 로그인 실패: \(error.localizedDescription)")
            }
        }
    }
    
    func checkLoginStatus() {
        self.isLoggedIn = (Auth.auth().currentUser != nil)
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
        } catch let error {
            print("로그아웃 에러: \(error.localizedDescription)")
        }
    }
}
