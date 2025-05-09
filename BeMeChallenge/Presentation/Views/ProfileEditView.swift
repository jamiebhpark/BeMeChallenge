// ProfileEditView.swift
import SwiftUI

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var profileViewModel: ProfileViewModel

    @State private var newNickname: String
    @State private var newBio: String
    @State private var newLocation: String

    @State private var isSaving = false
    @State private var errorMessage: String?

    init(profileViewModel: ProfileViewModel) {
        self.profileViewModel = profileViewModel
        _newNickname = State(initialValue: profileViewModel.nickname)
        _newBio      = State(initialValue: profileViewModel.bio)
        _newLocation = State(initialValue: profileViewModel.location)
    }

    private var avatarURL: URL? {
        guard let base = profileViewModel.profileImageURL else { return nil }
        if let v = profileViewModel.profileImageUpdatedAt {
            let sep = base.contains("?") ? "&" : "?"
            return URL(string: "\(base)\(sep)v=\(Int(v))")
        }
        return URL(string: base)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                avatarSection

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
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)    // ← hide default
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                        Text("프로필")
                    }
                }
            }
        }
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

    private var avatarSection: some View {
        Group {
            if let url = avatarURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .failure:
                        Image("defaultAvatar").resizable()
                    case .success(let img):
                        img.resizable().scaledToFill()
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image("defaultAvatar").resizable()
            }
        }
        .aspectRatio(contentMode: .fill)
        .frame(width: 120, height: 120)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white, lineWidth: 2))
        .shadow(radius: 6)
    }

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
                    isSaving = false
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
