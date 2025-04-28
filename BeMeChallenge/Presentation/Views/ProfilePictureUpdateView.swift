//
//  ProfilePictureUpdateView.swift
//  BeMeChallenge
//

import SwiftUI

struct ProfilePictureUpdateView: View {
    // 부모(예: ProfileEditView)에서 주입
    @ObservedObject var profileVM: ProfileViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var selectedImage: UIImage?
    @State private var isPickerPresented = false
    @State private var isUploading      = false
    @State private var uploadError: String?

    var body: some View {
        VStack(spacing: 20) {

            // ── 미리보기 썸네일 ────────────────────────────────
            Group {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                } else if
                    let urlString = profileVM.profileImageURL,
                    let url       = URL(string: urlString)
                {
                    AsyncCachedImage(
                        url: url,
                        content: { $0.resizable() },
                        placeholder: { Image("defaultAvatar").resizable() },
                        failure:     { Image("defaultAvatar").resizable() }
                    )
                } else {
                    Image("defaultAvatar")
                        .resizable()
                }
            }
            .aspectRatio(contentMode: .fill)
            .frame(width: 150, height: 150)
            .clipShape(Circle())
            .shadow(radius: 4)

            // ── 액션 버튼들 ────────────────────────────────────
            Button("프로필 사진 선택") { isPickerPresented = true }
                .buttonStyle(.borderedProminent)

            if isUploading { ProgressView("업로드 중…") }

            Button("사진 업데이트") {
                guard let img = selectedImage else { return }
                upload(img)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("PrimaryGradientEnd"))
            .foregroundColor(.white)
            .cornerRadius(10)

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

    // MARK: - Upload Helper
    private func upload(_ image: UIImage) {
        isUploading = true
        profileVM.updateProfilePicture(image) { result in
            DispatchQueue.main.async {
                isUploading = false
                switch result {
                case .success:
                    dismiss()               // 완료 후 화면 닫기
                case .failure(let err):
                    uploadError = err.localizedDescription
                }
            }
        }
    }
}
