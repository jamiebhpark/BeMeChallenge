//ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var profileViewModel = ProfileViewModel()
    
    var body: some View {
        VStack {
            // 프로필 상단 정보
            HStack {
                Image("defaultAvatar")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                VStack(alignment: .leading) {
                    Text("닉네임")
                        .font(.headline)
                    Text("가입일: 2024-01-01")
                        .font(.caption)
                }
                Spacer()
                Button(action: {
                    authViewModel.signOut()
                }) {
                    Text("로그아웃")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            // 달력형 참여 기록 뷰
            Text("챌린지 참여 달력")
                .font(.headline)
            CalendarView(viewModel: profileViewModel)
            
            Spacer()
        }
        .navigationTitle("프로필")  // 만약 이 뷰가 NavigationView 내에 있다면 NavigationTitle은 여기서 사용
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}
