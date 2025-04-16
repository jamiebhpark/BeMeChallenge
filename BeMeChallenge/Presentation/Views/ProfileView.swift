//ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var profileViewModel = ProfileViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // 프로필 헤더 영역
                    ProfileHeaderView(viewModel: profileViewModel)
                    
                    // 프로필 완성도 뷰
                    ProfileCompletionView(profileViewModel: profileViewModel)
                        .padding(.horizontal)
                    
                    // 챌린지 참여 달력 영역
                    VStack(alignment: .leading, spacing: 8) {
                        Text("챌린지 참여 달력")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        CalendarView(viewModel: profileViewModel.calendarViewModel)
                    }
                    
                    // 개인정보 설정 내비게이션 링크
                    NavigationLink(destination: ProfilePrivacyView()) {
                        HStack {
                            Text("개인정보 설정")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("프로필")
            .onAppear {
                profileViewModel.fetchUserProfile()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("로그아웃") {
                        authViewModel.signOut { result in
                            // 로그아웃 후 필요한 추가 처리(예: 로그인 화면 전환)
                        }
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}
