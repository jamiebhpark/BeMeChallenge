//AuthViewModel.swift
import SwiftUI
import FirebaseAuth
import Combine
import AuthenticationServices
import GoogleSignIn

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    private var authHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        // 인증 상태 리스너 추가
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            DispatchQueue.main.async {
                self?.isLoggedIn = (user != nil)
            }
        }
    }
    
    deinit {
        if let handle = authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
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
    
    // MARK: - 현재 로그인 상태 확인 및 강제 새로고침
    func checkLoginStatus() {
        // 현재 사용자가 있다면 최신 상태 반영을 위해 reload() 호출
        Auth.auth().currentUser?.reload { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("사용자 재로딩 실패: \(error.localizedDescription)")
                }
                self?.isLoggedIn = (Auth.auth().currentUser != nil)
            }
        }
    }
    
    // MARK: - 로그아웃 및 온보딩 플래그 초기화
    func signOut(completion: ((Result<Void, Error>) -> Void)? = nil) {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut() // Google 로그아웃 처리
            // 계정 삭제나 로그아웃 시, 온보딩 플래그를 초기화하여 새 가입 시 온보딩을 다시 표시
            UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
            DispatchQueue.main.async {
                self.isLoggedIn = false
                completion?(.success(()))
            }
        } catch let error {
            print("로그아웃 에러: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
        }
    }
}
