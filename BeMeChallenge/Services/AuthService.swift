import Foundation
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import SwiftUI
import FirebaseCore
import CryptoKit

class AuthService: NSObject, ObservableObject {
    static let shared = AuthService()

    // MARK: - Google Sign In
    func signInWithGoogle(presenting: UIViewController,
                          completion: @escaping (Result<User, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(NSError(domain: "AuthService",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Missing clientID"])))
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        Task {
            do {
                let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting,
                                                                               hint: nil,
                                                                               additionalScopes: [])

                // 1. idToken은 옵셔널이므로 안전하게 추출하고, accessToken은 바로 사용
                guard let idToken = signInResult.user.idToken?.tokenString, // idToken은 옵셔널 바인딩
                      !idToken.isEmpty, // idToken이 비어있지 않은지 확인
                      // accessToken은 옵셔널이 아니므로 바로 .tokenString에 접근하고 비어있는지만 확인
                      !signInResult.user.accessToken.tokenString.isEmpty else {

                    completion(.failure(NSError(domain: "AuthService",
                                                code: -1,
                                                userInfo: [NSLocalizedDescriptionKey: "Google ID token or Access token is missing or empty."])))
                    return // 토큰이 없거나 비어있으면 함수 종료
                }

                // guard 문을 통과했으므로 idToken은 유효한 String 값임
                // accessToken도 여기서 바로 가져와서 사용
                let accessToken = signInResult.user.accessToken.tokenString

                // 2. Firebase credential 생성
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: accessToken) // 이제 idToken과 accessToken 모두 유효한 String

                // 3. Firebase에 로그인
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    if let firebaseUser = authResult?.user {
                        completion(.success(firebaseUser))
                    } else {
                        completion(.failure(NSError(domain: "AuthService",
                                                    code: -2,
                                                    userInfo: [NSLocalizedDescriptionKey: "Firebase authentication failed: User data is missing."])))
                    }
                }

            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Apple Sign In
    // currentNonce 관리 및 nonce 생성 로직 필요 (여기서는 간략화)
    fileprivate var currentNonce: String?

    // Nonce 생성 함수 예시 (실제 앱에서는 더 안전한 방법 사용 권장)
    func generateNonce(length: Int = 32) -> String {
        // 실제 구현에서는 CryptoKit 등을 사용하여 안전하게 생성해야 합니다.
        // 이 예시는 설명을 위한 단순 문자열 생성입니다.
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        for _ in 0..<length {
            let random = Int(arc4random_uniform(UInt32(charset.count)))
            result.append(charset[random])
        }
        self.currentNonce = result // 생성된 nonce 저장
        return result
    }


    func handleAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
        let nonce = generateNonce() // 요청 시 Nonce 생성 및 저장
        request.nonce = sha256(nonce) // SHA256 해시값 사용
    }

    // SHA256 해시 함수 (Apple 로그인 Nonce에 필요)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }


    func signInWithApple(credential: ASAuthorizationAppleIDCredential,
                         completion: @escaping (Result<User, Error>) -> Void) {
        guard let nonce = currentNonce else { // 저장된 Nonce 사용
            completion(.failure(NSError(domain: "AuthService",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Invalid state: No nonce found."])))
            return
        }
        // Nonce 사용 후 초기화 (재사용 방지)
        // self.currentNonce = nil // 필요에 따라 주석 해제

        guard let appleIDToken = credential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            completion(.failure(NSError(domain: "AuthService",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"])))
            return
        }
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce) // rawNonce 전달
        Auth.auth().signIn(with: firebaseCredential) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let firebaseUser = authResult?.user {
                completion(.success(firebaseUser))
            } else {
                completion(.failure(NSError(domain: "AuthService",
                                            code: -2,
                                            userInfo: [NSLocalizedDescriptionKey: "Firebase authentication failed: User data is missing."])))
            }
        }
    }

    // MARK: - Sign Out
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut() // Google 로그아웃도 함께 처리
            completion(.success(()))
        } catch let error {
            completion(.failure(error))
        }
    }
}
