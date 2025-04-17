// ProfileView.swift
import SwiftUI

/// “떠 있는 카드” 스타일의 공통 섹션 컴포넌트
struct CardSection<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        VStack { content }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            .padding(.horizontal)
    }
}

/// 재사용 가능한 설정 행 컴포넌트 (Destination 뷰를 클로저로 주입)
struct SettingsRow<Destination: View>: View {
    let title: String
    let destination: () -> Destination

    var body: some View {
        NavigationLink(destination: destination()) {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
    }
}

/*struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var profileVM = ProfileViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // 1) 프로필 헤더
                        CardSection {
                            ProfileHeaderView(viewModel: profileVM)
                        }

                        // 2) 연속 참여 Streak
                        CardSection {
                            StreakView()
                        }

                        // 3) 프로필 완성도
                        CardSection {
                            ProfileCompletionView(profileViewModel: profileVM)
                        }

                        // 4) 참여 달력
                        CardSection {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("챌린지 참여 달력")
                                    .font(.headline)
                                CalendarView(viewModel: profileVM.calendarViewModel)
                            }
                        }

                        // 5) 개인정보 설정
                        CardSection {
                            SectionHeader(title: "개인정보")
                            SettingsRow(title: "개인정보 설정") {
                                ProfilePrivacyView()
                                    .environmentObject(authViewModel)
                            }
                        }

                        // 6) 지원 섹션
                        CardSection {
                            SectionHeader(title: "지원")
                            SettingsRow(title: "앱 정보") { AboutView() }
                            SettingsRow(title: "도움말 & FAQ") { HelpFAQView() }
                            SettingsRow(title: "피드백 보내기") { FeedbackView() }
                        }

                        Spacer(minLength: 32)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("프로필")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("로그아웃") {
                        authViewModel.signOut()
                    }
                    .foregroundColor(.red)
                    .font(.subheadline.bold())
                }
            }
            .onAppear { profileVM.fetchUserProfile() }
        }
    }
}*/

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var profileVM = ProfileViewModel()

    var body: some View {
        NavigationView {
            List {
                // 프로필 헤더
                Section {
                    ProfileHeaderView(viewModel: profileVM)
                }

                // 성과(연속 참여 + 완성도)
                Section(header: Text("나의 성과")) {
                    StreakView()
                    ProfileCompletionView(profileViewModel: profileVM)
                }

                // 달력
                Section(header: Text("참여 달력")) {
                    CalendarView(viewModel: profileVM.calendarViewModel)
                        .frame(height: 250)
                }

                // 개인정보
                Section(header: Text("개인정보")) {
                    NavigationLink("개인정보 설정") {
                        ProfilePrivacyView()
                            .environmentObject(authViewModel)
                    }
                }

                // 지원
                Section(header: Text("지원")) {
                    NavigationLink("앱 정보", destination: AboutView())
                    NavigationLink("도움말 & FAQ", destination: HelpFAQView())
                    NavigationLink("피드백 보내기", destination: FeedbackView())
                }

                // 로그아웃
                Section {
                    Button("로그아웃", role: .destructive) {
                        authViewModel.signOut()
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .onAppear { profileVM.fetchUserProfile() }
        }
    }
}
