//
//  ProfileFeedView.swift
//  BeMeChallenge
//

import SwiftUI

struct ProfileFeedView: View {
    // 부모 뷰에서 주입
    @ObservedObject var profileVM: ProfileViewModel
    let initialID: String

    @EnvironmentObject private var modalC: ModalCoordinator

    var body: some View {
        Group {
            switch profileVM.profileState {

            // ── 로딩
            case .idle, .loading:
                ProgressView()
                    .frame(maxHeight: .infinity)
                    .onAppear { Task { @MainActor in profileVM.refresh() } }

            // ── 실패
            case .failed(let err):
                VStack(spacing: 16) {
                    Text("로드 실패: \(err.localizedDescription)")
                    Button("재시도") { Task { @MainActor in profileVM.refresh() } }
                }
                .padding()

            // ── 성공
            case .loaded(let profile):
                // 자신(User) 캐싱
                let me = User(
                    id: profile.id ?? "",
                    nickname: profile.nickname,
                    bio: profile.bio,
                    location: profile.location,
                    profileImageURL: profile.profileImageURL,
                    profileImageUpdatedAt: profile.profileImageUpdatedAt, // ⬅︎ Double 그대로 전달
                    fcmToken: nil
                )

                FeedView(
                    posts:         profileVM.userPosts,
                    userCache:     [me.id!: me],      // me.id 는 String
                    initialPostID: initialID,
                    onLike:        { _ in },
                    onReport:      { _ in },
                    onDelete:      { post in
                        Task { @MainActor in
                            profileVM.deletePost(post)
                            modalC.showToast(ToastItem(message: "삭제 완료"))
                        }
                    }
                )
                .navigationTitle("내 포스트")
                .navigationBarTitleDisplayMode(.inline)
                .alert(item: $modalC.modalAlert, content: buildAlert)
            }
        }
    }

    // MARK: - Alert builder
    private func buildAlert(for alert: ModalAlert) -> Alert {
        switch alert {
        case .manage(let post):
            return Alert(
                title: Text("게시물 관리"),
                primaryButton: .destructive(Text("삭제")) {
                    modalC.showAlert(.deleteConfirm(post: post))
                },
                secondaryButton: .default(Text("신고")) {
                    modalC.showAlert(.reportConfirm(post: post))
                }
            )

        case .deleteConfirm(let post):
            return Alert(
                title: Text("삭제 확인"),
                message: Text("정말 삭제하시겠습니까?"),
                primaryButton: .destructive(Text("삭제")) {
                    Task { @MainActor in
                        profileVM.deletePost(post)
                        modalC.resetAlert()
                        modalC.showToast(ToastItem(message: "삭제 완료"))
                    }
                },
                secondaryButton: .cancel {
                    modalC.resetAlert()
                }
            )

        case .reportConfirm(let post):
            return Alert(
                title: Text("신고 확인"),
                message: Text("이 게시물을 신고하시겠습니까?"),
                primaryButton: .destructive(Text("신고")) {
                    Task { @MainActor in
                        profileVM.reportPost(post)
                        modalC.resetAlert()
                        modalC.showToast(ToastItem(message: "신고 접수"))
                    }
                },
                secondaryButton: .cancel {
                    modalC.resetAlert()
                }
            )
        }
    }
}
