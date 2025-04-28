// ProfileEditView.swift
// BeMeChallenge

import SwiftUI

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var profileViewModel: ProfileViewModel

    // 입력값
    @State private var newNickname: String
    @State private var newBio: String
    @State private var newLocation: String

    // 진행 상태
    @State private var isSaving = false
    @State private var errorMessage: String?

    // MARK: - 초기화
    init(profileViewModel: ProfileViewModel) {
        self.profileViewModel = profileViewModel
        _newNickname = State(initialValue: profileViewModel.nickname)
        _newBio      = State(initialValue: profileViewModel.bio)
        _newLocation = State(initialValue: profileViewModel.location)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 프로필 사진 & 변경
                    VStack(spacing: 12) {
                        Group {
                            if let urlString = profileViewModel.profileImageURL,
                               let url = URL(string: urlString) {
                                AsyncCachedImage(
                                    url: url,
                                    content: { $0.resizable() },
                                    placeholder: { Image("defaultAvatar").resizable() },
                                    failure:     { Image("defaultAvatar").resizable() }
                                )
                            } else {
                                Image("defaultAvatar").resizable()
                            }
                        }
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .shadow(radius: 6)

                        NavigationLink {
                            ProfilePictureUpdateView(profileVM: profileViewModel)
                        } label: {
                            Text("프로필 사진 변경")
                                .font(.subheadline.bold())
                                .padding(.vertical, 8)
                                .padding(.horizontal, 20)
                                .background(Color(.systemGray5))
                                .cornerRadius(20)
                        }
                    }
                    .padding(.top, 20)

                    // 닉네임 / 자기소개 / 위치
                    EditableField(
                        title: "닉네임",
                        text: $newNickname,
                        placeholder: "새 닉네임을 입력하세요"
                    )
                    EditableField(
                        title: "자기소개",
                        text: $newBio,
                        placeholder: "자기소개를 입력하세요"
                    )
                    EditableField(
                        title: "위치",
                        text: $newLocation,
                        placeholder: "거주지를 입력하세요"
                    )

                    // 저장 버튼
                    if isSaving {
                        ProgressView("저장 중…")
                            .frame(maxWidth: .infinity)
                    } else {
                        Button(action: saveProfileChanges) {
                            Text("저장")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color("PrimaryGradientEnd"))
                                .cornerRadius(12)
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
            }
            .navigationTitle("프로필 편집")
            .alert(
                "오류",
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { _ in errorMessage = nil }
                )
            ) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    // MARK: - 저장 로직
    private func saveProfileChanges() {
        isSaving = true
        profileViewModel.updateNickname(to: newNickname) { nickOK in
            guard nickOK else {
                setError("닉네임 업데이트에 실패했습니다.")
                return
            }
            profileViewModel.updateAdditionalInfo(
                bio: newBio,
                location: newLocation
            ) { infoOK in
                DispatchQueue.main.async {
                    self.isSaving = false
                    if infoOK {
                        dismiss()
                    } else {
                        setError("추가 정보 업데이트에 실패했습니다.")
                    }
                }
            }
        }
    }

    private func setError(_ msg: String) {
        isSaving     = false
        errorMessage = msg
    }
}

// MARK: - 소형 컴포넌트
private struct EditableField: View {
    let title: String
    @Binding var text: String
    let placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)
        }
    }
}
