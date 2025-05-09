// Presentation/Views/ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @StateObject private var vm = ProfileViewModel()

    @State private var navPath      = NavigationPath()
    @State private var showSettings = false

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 4),
        count: 3
    )

    var body: some View {
        NavigationStack(path: $navPath) {
            List {
                // ── 헤더
                Section {
                    ProfileHeaderView(viewModel: vm)
                        .onTapGesture {
                            navPath.append(ProfileDestination.editProfile)
                        }
                        .listRowInsets(.init())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }

                // ── 연속 & 총 참여
                Section(header: Text("나의 성과")) {
                    StreakView(
                        totalParticipations: vm.totalParticipations,
                        streakDays:          vm.currentStreak
                    )
                    .listRowBackground(Color(.systemBackground))
                }

                // ── 내 포스트 썸네일 그리드
                Section(header: Text("내 포스트")) {
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(vm.userPosts) { post in
                            Button {
                                // **한 번만** 피드 화면으로 이동
                                if let id = post.id {
                                    navPath.append(ProfileDestination.feed(initialPostID: id))
                                }
                            } label: {
                                ThumbnailView(url: URL(string: post.imageUrl))
                                    .frame(height: 100)
                                    .clipped()
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                    .listRowInsets(.init())
                    .listRowBackground(Color(.systemBackground))
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("프로필")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                            .font(.title3)
                    }
                    .sheet(isPresented: $showSettings) {
                        SettingsView().environmentObject(authVM)
                    }
                }
            }
            // === 네비게이션 목적지 선언 ===
            .navigationDestination(for: ProfileDestination.self) { dest in
                switch dest {
                case .editProfile:
                    ProfileEditView(profileViewModel: vm)
                case .feed(let initialID):
                    UserPostListView(
                        profileVM: vm,
                        initialPostID: initialID
                    )
                }
            }
        }
    }
}

/// ProfileView.swift 옆에 추가
enum ProfileDestination: Hashable {
    case editProfile
    case feed(initialPostID: String)
}
