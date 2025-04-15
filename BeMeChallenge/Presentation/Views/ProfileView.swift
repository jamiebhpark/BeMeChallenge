//ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var profileViewModel = ProfileViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // 1. 프로필 헤더 영역
                    ProfileHeaderView(viewModel: profileViewModel)
                    
                    // 2. 프로필 완성도 뷰
                    ProfileCompletionView()
                        .padding(.horizontal)
                    
                    // 3. 챌린지 참여 달력 영역
                    VStack(alignment: .leading, spacing: 8) {
                        Text("챌린지 참여 달력")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        CalendarView(viewModel: profileViewModel.calendarViewModel)
                    }
                    
                    // 4. 개인정보 설정 내비게이션 링크
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
        }
    }
}
