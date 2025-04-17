// ProfileEditView.swift
import SwiftUI

struct ProfileEditView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var profileViewModel: ProfileViewModel
    
    @State private var newNickname: String = ""
    @State private var newBio: String = ""
    @State private var newLocation: String = ""
    @State private var selectedImage: UIImage? = nil
    
    @State private var isPickerPresented = false
    @State private var isSaving = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 프로필 사진
                    VStack {
                        ZStack {
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                            } else if let urlString = profileViewModel.profileImageURL,
                                      let url = URL(string: urlString) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView().frame(width: 120, height: 120)
                                    case .success(let image):
                                        image.resizable().scaledToFill()
                                    case .failure:
                                        Image("defaultAvatar").resizable().scaledToFill()
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Image("defaultAvatar").resizable().scaledToFill()
                            }
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .shadow(radius: 6)
                        
                        Button {
                            isPickerPresented = true
                        } label: {
                            Label("사진 선택", systemImage: "photo")
                                .font(.subheadline)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color(.systemGray5))
                                .cornerRadius(20)
                        }
                    }
                    .padding(.top, 20)
                    
                    // 닉네임
                    VStack(alignment: .leading, spacing: 8) {
                        Text("닉네임").font(.headline)
                        TextField("새 닉네임을 입력하세요", text: $newNickname)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    // 자기소개
                    VStack(alignment: .leading, spacing: 8) {
                        Text("자기소개").font(.headline)
                        TextField("자기소개를 입력하세요", text: $newBio)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    // 위치
                    VStack(alignment: .leading, spacing: 8) {
                        Text("위치").font(.headline)
                        TextField("거주지를 입력하세요", text: $newLocation)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    // 저장 버튼
                    VStack {
                        if isSaving {
                            ProgressView("저장 중...")
                                .frame(maxWidth: .infinity)
                        } else {
                            Button {
                                saveProfileChanges()
                            } label: {
                                Text("저장")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color("PrimaryGradientEnd"))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("프로필 편집")
            .onAppear {
                // 초기값 세팅
                newNickname = profileViewModel.nickname
                newBio = profileViewModel.bio
                newLocation = profileViewModel.location
            }
            .sheet(isPresented: $isPickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .alert("오류", isPresented: Binding<Bool>(
                get: { errorMessage != nil },
                set: { _ in errorMessage = nil }
            )) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
    
    private func saveProfileChanges() {
        isSaving = true
        // 1) 닉네임
        profileViewModel.updateNickname(to: newNickname) { success in
            guard success else {
                errorMessage = "닉네임 업데이트에 실패했습니다."
                isSaving = false
                return
            }
            // 2) bio + location
            profileViewModel.updateAdditionalInfo(bio: newBio, location: newLocation) { ok in
                guard ok else {
                    errorMessage = "추가 정보 업데이트에 실패했습니다."
                    isSaving = false
                    return
                }
                // 3) 사진
                if let img = selectedImage {
                    profileViewModel.updateProfilePicture(img) { result in
                        DispatchQueue.main.async {
                            isSaving = false
                            switch result {
                            case .success:
                                dismiss()
                            case .failure(let err):
                                errorMessage = err.localizedDescription
                            }
                        }
                    }
                } else {
                    isSaving = false
                    dismiss()
                }
            }
        }
    }
}
