// ProfileThemeViewModel.swift
import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ProfileTheme: Identifiable, Hashable {
    var id: String { name }
    var name: String
    var description: String
    var previewColor: Color
}

class ProfileThemeViewModel: ObservableObject {
    @Published var themes: [ProfileTheme] = []
    @Published var selectedTheme: ProfileTheme?
    
    private let db = Firestore.firestore()
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    init() {
        loadThemes()
        fetchCurrentTheme()
    }
    
    // 사용 가능한 테마 옵션을 로드합니다.
    func loadThemes() {
        themes = [
            ProfileTheme(name: "Light", description: "밝고 깔끔한 테마", previewColor: .white),
            ProfileTheme(name: "Dark", description: "어두워진 모드로 집중력을 높여요", previewColor: .black),
            ProfileTheme(name: "Blue", description: "시원한 블루 톤", previewColor: .blue),
            ProfileTheme(name: "Green", description: "자연을 닮은 그린 테마", previewColor: .green)
        ]
    }
    
    // 현재 사용자의 테마를 Firestore에서 가져옵니다.
    func fetchCurrentTheme() {
        guard let uid = userId else { return }
        db.collection("users").document(uid).getDocument { [weak self] document, error in
            if let error = error {
                print("프로필 테마 조회 에러: \(error.localizedDescription)")
                return
            }
            if let data = document?.data(), let themeName = data["profileTheme"] as? String {
                DispatchQueue.main.async {
                    self?.selectedTheme = self?.themes.first(where: { $0.name == themeName })
                }
            }
        }
    }
    
    // 사용자가 선택한 테마를 업데이트합니다.
    func selectTheme(_ theme: ProfileTheme) {
        selectedTheme = theme
    }
    
    // 선택한 테마를 Firestore에 저장합니다.
    func saveSelectedTheme(completion: @escaping (Bool) -> Void) {
        guard let uid = userId, let selectedTheme = selectedTheme else {
            completion(false)
            return
        }
        db.collection("users").document(uid).updateData([
            "profileTheme": selectedTheme.name
        ]) { error in
            if let error = error {
                print("테마 업데이트 에러: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
