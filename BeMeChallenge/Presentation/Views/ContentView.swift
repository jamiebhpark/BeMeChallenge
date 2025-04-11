// ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                MainTabView() // 메인 탭(홈, 촬영, 프로필)
            } else {
                LoginView()   // 소셜 로그인 화면
            }
        }
        .onAppear {
            authViewModel.checkLoginStatus()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
