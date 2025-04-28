//AuthService.swift
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
        
        // MainActor 보장을 위해 Task에 @MainActor 지정
        Task { @MainActor in
            do {
                let signInResult = try await GIDSignIn.sharedInstance.signIn(
                    withPresenting: presenting,
                    hint: nil,
                    additionalScopes: []
                )
                // idToken 및 accessToken 추출
                guard let idToken = signInResult.user.idToken?.tokenString,
                      !idToken.isEmpty,
                      !signInResult.user.accessToken.tokenString.isEmpty else {
                    completion(.failure(NSError(domain: "AuthService",
                                                code: -1,
                                                userInfo: [NSLocalizedDescriptionKey: "Google ID token or Access token is missing or empty."])))
                    return
                }
                
                let accessToken = signInResult.user.accessToken.tokenString
                
                // Firebase credential 생성
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: accessToken)
                // Firebase에 로그인 (Firebase API는 내부적으로 메인 스레드 접근을 요구)
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    if let firebaseUser = authResult?.user {
                        let domainUser = User(from: firebaseUser)
                        completion(.success(domainUser))
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
    fileprivate var currentNonce: String?
    
    func generateNonce(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        for _ in 0..<length {
            let random = Int(arc4random_uniform(UInt32(charset.count)))
            result.append(charset[random])
        }
        self.currentNonce = result
        return result
    }
    
    func handleAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
        let nonce = generateNonce()
        request.nonce = sha256(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.map { String(format: "%02x", $0) }.joined()
    }
    
    func signInWithApple(credential: ASAuthorizationAppleIDCredential,
                         completion: @escaping (Result<User, Error>) -> Void) {
        guard let nonce = currentNonce else {
            completion(.failure(NSError(domain: "AuthService",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Invalid state: No nonce found."])))
            return
        }
        guard let appleIDToken = credential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            completion(.failure(NSError(domain: "AuthService",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"])))
            return
        }
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
        Auth.auth().signIn(with: firebaseCredential) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let firebaseUser = authResult?.user {
                let domainUser = User(from: firebaseUser)
                completion(.success(domainUser))
            } else {
                completion(.failure(NSError(domain: "AuthService",
                                            code: -2,
                                            userInfo: [NSLocalizedDescriptionKey: "Firebase authentication failed: User data is missing."])))
            }
        }
    }
    
    // MARK: - 재인증 메서드 (Google)
    func reauthenticateWithGoogle(presenting: UIViewController,
                                  completion: @escaping (Result<AuthCredential, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(NSError(domain: "AuthService",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Missing clientID"])))
            return
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        Task { @MainActor in
            do {
                let signInResult = try await GIDSignIn.sharedInstance.signIn(
                    withPresenting: presenting,
                    hint: nil,
                    additionalScopes: []
                )
                guard let idToken = signInResult.user.idToken?.tokenString,
                      !idToken.isEmpty,
                      !signInResult.user.accessToken.tokenString.isEmpty else {
                    throw NSError(domain: "AuthService",
                                  code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "Google ID token or Access token is missing or empty."])
                }
                let accessToken = signInResult.user.accessToken.tokenString
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: accessToken)
                completion(.success(credential))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 재인증 메서드 (Apple)
    // Apple 재인증의 경우, 보통 앱 재로그인을 유도하는 것이 권장되므로,
    // 필요시 별도의 로직 또는 안내 메시지를 제공하는 방식으로 처리합니다.
    func reauthenticateWithApple(credential: ASAuthorizationAppleIDCredential,
                                 completion: @escaping (Result<AuthCredential, Error>) -> Void) {
        guard let nonce = currentNonce else {
            completion(.failure(NSError(domain: "AuthService",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Invalid state: No nonce found."])))
            return
        }
        guard let appleIDToken = credential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            completion(.failure(NSError(domain: "AuthService",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"])))
            return
        }
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
        // Apple 재인증 역시, UI 접근이 필요한 경우 메인 액터에서 호출하도록 필요시 수정할 수 있습니다.
        completion(.success(firebaseCredential))
    }
    
    // MARK: - Sign Out
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}

