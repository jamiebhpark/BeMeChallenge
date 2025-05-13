// Presentation/Features/Profile/ProfileFeedView.swift
import SwiftUI

struct ProfileFeedView: View {
    @ObservedObject var profileVM: ProfileViewModel
    let initialID: String

    @EnvironmentObject private var modalC: ModalCoordinator

    var body: some View {
        Group {
            switch profileVM.profileState {
            case .idle, .loading:
                ProgressView()
                    .frame(maxHeight: .infinity)
                    .onAppear { profileVM.refresh() }

            case .failed(let error):
                VStack(spacing: 16) {
                    Text("로드 실패: \(error.localizedDescription)")
                    Button("재시도") { profileVM.refresh() }
                }
                .padding()

            case .loaded(let profile):
                // 내 사용자 도메인 모델 생성
                let me = User(
                    id: profile.id!,
                    nickname: profile.nickname,
                    bio: profile.bio,
                    location: profile.location,
                    profileImageURL: profile.profileImageURL,
                    profileImageUpdatedAt: profile.profileImageUpdatedAt?.timeIntervalSince1970,
                    isProfilePublic: true,
                    fcmToken: nil
                )

                FeedView(
                    posts:         profileVM.userPosts,
                    userCache:     [me.id: me],
                    initialPostID: initialID,
                    onLike:        { _ in },
                    onReport:      { _ in },
                    onDelete:      { post in
                        // 삭제 버튼 처리
                        profileVM.deletePost(post)
                        modalC.showToast(ToastItem(message: "삭제 완료"))
                    }
                )
                .navigationTitle("내 포스트")
                .navigationBarTitleDisplayMode(.inline)
                .alert(item: $modalC.modalAlert, content: buildAlert)
            }
        }
    }

    // MARK: Alert builder
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
                    profileVM.deletePost(post)
                    modalC.resetAlert()
                    modalC.showToast(ToastItem(message: "삭제 완료"))
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
                    profileVM.reportPost(post)
                    modalC.resetAlert()
                    modalC.showToast(ToastItem(message: "신고 접수"))
                },
                secondaryButton: .cancel {
                    modalC.resetAlert()
                }
            )
        }
    }
}
