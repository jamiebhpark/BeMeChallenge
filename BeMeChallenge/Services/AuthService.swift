// AuthService.swift
import Foundation
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import SwiftUI
import FirebaseCore

class AuthService: NSObject, ObservableObject {
    static let shared = AuthService()
    
    // MARK: - Google Sign In
    func signInWithGoogle(presenting: UIViewController, completion: @escaping (Result<User, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing clientID"])))
            return
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: presenting) { user, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let authentication = user?.authentication,
                  let idToken = authentication.idToken else {
                completion(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google authentication error"])))
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let firebaseUser = result?.user {
                    completion(.success(firebaseUser))
                }
            }
        }
    }
    
    // MARK: - Apple Sign In
    // currentNonce 관리 및 nonce 생성 로직 필요 (여기서는 간략화)
    fileprivate var currentNonce: String?
    
    func signInWithApple(credential: ASAuthorizationAppleIDCredential,
                         completion: @escaping (Result<User, Error>) -> Void) {
        guard let nonce = currentNonce else {
            completion(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid state: No nonce found."])))
            return
        }
        guard let appleIDToken = credential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            completion(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"])))
            return
        }
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
        Auth.auth().signIn(with: firebaseCredential) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let firebaseUser = authResult?.user {
                completion(.success(firebaseUser))
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch let error {
            completion(.failure(error))
        }
    }
}
