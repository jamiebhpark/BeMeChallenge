import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @ObservedObject var authViewModel: AuthViewModel  // 환경 객체에서 주입받은 모델 사용

    var body: some View {
        VStack(spacing: 20) {
            Text("BeMe Challenge")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Google 로그인 버튼
            Button(action: {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    authViewModel.loginWithGoogle(using: rootVC)
                }
            }) {
                Text("Google 로그인")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            
            // Apple 로그인 버튼
            SignInWithAppleButton(
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                    AuthService.shared.handleAppleSignInRequest(request)
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                            authViewModel.loginWithApple(using: appleIDCredential)
                        }
                    case .failure(let error):
                        print("Apple 로그인 실패: \(error.localizedDescription)")
                    }
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 50)
            .cornerRadius(8)
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        // 미리보기에서는 임의로 AuthViewModel을 생성합니다.
        LoginView(authViewModel: AuthViewModel())
    }
}
