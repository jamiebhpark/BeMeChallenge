// Presentation/Views/ProfilePictureUpdateView.swift
import SwiftUI

struct ProfilePictureUpdateView: View {
    @ObservedObject var profileVM: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImage: UIImage?
    @State private var isPickerPresented = false
    @State private var isUploading      = false
    @State private var uploadError: String?

    private var avatarURL: URL? {
        guard let base = profileVM.profileImageURL else { return nil }
        if let v = profileVM.profileImageUpdatedAt {
            let sep = base.contains("?") ? "&" : "?"
            return URL(string: "\(base)\(sep)v=\(Int(v))")
        }
        return URL(string: base)
    }

    var body: some View {
        VStack(spacing: 24) {
            // ── 미리보기 썸네일 ────────────────────────────────
            Group {
                if let image = selectedImage {
                    Image(uiImage: image).resizable().scaledToFill()
                } else if let url = avatarURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:    ProgressView()
                        case .failure:  Image("defaultAvatar").resizable()
                        case .success(let img): img.resizable().scaledToFill()
                        @unknown default: EmptyView()
                        }
                    }
                    .id(url)
                } else {
                    Image("defaultAvatar").resizable()
                }
            }
            .frame(width: 150, height: 150)
            .clipShape(Circle())
            .shadow(radius: 4)

            // ── 액션 버튼들 ────────────────────────────────────
            VStack(spacing: 16) {
                // 사진 선택
                Button("프로필 사진 선택") {
                    isPickerPresented = true
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)

                // 기본 아바타로 되돌리기
                Button("기본 아바타로 되돌리기") {
                    // ViewModel에 resetProfilePicture() 구현 필요
                    profileVM.resetProfilePicture()
                    dismiss()
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)

                // 사진 업데이트
                Button("사진 업데이트") {
                    guard let img = selectedImage else { return }
                    upload(img)
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            }

            if isUploading {
                ProgressView("업로드 중…")
                    .padding(.top, 8)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("프로필 사진 변경")
        .sheet(isPresented: $isPickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .alert("업로드 오류",
               isPresented: Binding(get: { uploadError != nil },
                                    set: { _ in uploadError = nil })) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(uploadError ?? "")
        }
    }

    private func upload(_ image: UIImage) {
        isUploading = true
        profileVM.updateProfilePicture(image) { result in
            DispatchQueue.main.async {
                isUploading = false
                switch result {
                case .success:
                    dismiss()
                case .failure(let err):
                    uploadError = err.localizedDescription
                }
            }
        }
    }
}

