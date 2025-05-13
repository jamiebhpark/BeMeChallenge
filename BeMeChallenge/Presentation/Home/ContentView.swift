//ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                MainTabView() // 메인 탭 (홈, 촬영, 프로필)
            } else {
                LoginView(authViewModel: authViewModel) // 공유된 authViewModel 전달
            }
        }
        .onAppear {
            authViewModel.checkLoginStatus()
        }
    }
}
