// ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var profileVM = ProfileViewModel()
    @State private var showEdit = false

    var body: some View {
        NavigationStack {
            List {
                // MARK: - 프로필 헤더 (터치 → 편집)
                Section {
                    ProfileHeaderView(viewModel: profileVM)
                        .onTapGesture { showEdit = true }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                
                // MARK: - 나의 성과
                Section(header: Text("나의 성과")) {
                    StreakView()
                }
                
                // MARK: - 참여 달력
                Section(header: Text("참여 달력")) {
                    CalendarView(viewModel: profileVM.calendarViewModel)
                        .frame(height: 250)
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                        )
                }

                // MARK: - 개인정보
                Section(header: Text("개인정보")) {
                    NavigationLink("개인정보 설정") {
                        ProfilePrivacyView()
                            .environmentObject(authViewModel)
                    }
                }

                // MARK: - 지원
                Section(header: Text("지원")) {
                    NavigationLink("앱 정보", destination: AboutView())
                    NavigationLink("도움말 & FAQ", destination: HelpFAQView())
                    NavigationLink("피드백 보내기", destination: FeedbackView())
                }

                // MARK: - 로그아웃
                Section {
                    Button("로그아웃", role: .destructive) {
                        authViewModel.signOut()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("프로필")
            // 더 이상 fetchUserProfile() 호출이 필요 없습니다.
            // .onAppear { /* nothing */ }

            // iOS16+ 전용: showEdit 바인딩으로 편집 화면 띄우기
            .navigationDestination(isPresented: $showEdit) {
                ProfileEditView(profileViewModel: profileVM)
            }
        }
    }
}
