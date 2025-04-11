// LoginView.swift
import SwiftUI

struct LoginView: View {
    @StateObject var authViewModel = AuthViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("BeMe Challenge")
                .font(.largeTitle)
                .fontWeight(.bold)
            Button(action: {
                authViewModel.loginWithGoogle()
            }) {
                Text("Google 로그인")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            Button(action: {
                authViewModel.loginWithApple()
            }) {
                Text("Apple 로그인")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
