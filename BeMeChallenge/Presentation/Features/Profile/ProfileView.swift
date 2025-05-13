// Presentation/Features/Profile/ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @StateObject private var vm = ProfileViewModel()
    @StateObject private var streakVM = StreakViewModel()
    private let grid = Array(repeating: GridItem(.flexible(), spacing: 4), count: 3)

    var body: some View {
        Group {
            switch vm.profileState {
            case .idle, .loading:
                ProgressView()
                    .frame(maxHeight: .infinity)

            case .failed(let err):
                VStack(spacing: 16) {
                    Text("로드 실패: \(err.localizedDescription)")
                    Button("재시도") { vm.refresh() }
                }
                .padding()

            case .loaded(let profile):
                ScrollView {
                    VStack(spacing: 20) {
                        // ── 프로필 헤더 카드
                        ProfileHeaderView(profile: profile) {
                            NavigationLink {
                                ProfileEditView(vm: vm)
                            } label: {
                                Image(systemName: "pencil")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)

                        // ── Streak 카드
                        VStack(alignment: .leading, spacing: 12) {
                            Text("연속 참여")
                                .font(.headline)
                                .padding(.horizontal)
                            StreakView(
                                totalParticipations: vm.userPosts.count,
                                streakDays: streakVM.currentStreak
                            )
                            .padding()
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal)

                        // ── 내 포스트 카드
                        VStack(alignment: .leading, spacing: 12) {
                            Text("내 포스트")
                                .font(.headline)
                                .padding(.horizontal)
                            LazyVGrid(columns: grid, spacing: 4) {
                                ForEach(vm.userPosts) { post in
                                    NavigationLink {
                                        ProfileFeedView(profileVM: vm, initialID: post.id!)
                                    } label: {
                                        ThumbnailView(url: URL(string: post.imageUrl))
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                .onAppear {
                    streakVM.fetchAndCalculateStreak()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsRootView()
                } label: {
                    Image(systemName: "gearshape")
                        .font(.title3)
                }
            }
        }
        .onAppear {
            vm.refresh()
        }
    }
}
