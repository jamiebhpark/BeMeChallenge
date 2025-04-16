// ProfileEditView.swift
import SwiftUI

struct ProfileEditView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var profileViewModel: ProfileViewModel
    @State private var newNickname: String = ""
    @State private var newBio: String = ""
    @State private var newLocation: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var isPickerPresented: Bool = false
    @State private var isSaving: Bool = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 프로필 사진 섹션
                    VStack {
                        ZStack {
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                            } else if let urlString = profileViewModel.profileImageURL, let url = URL(string: urlString) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView().frame(width: 120, height: 120)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    case .failure:
                                        Image("defaultAvatar")
                                            .resizable()
                                            .scaledToFill()
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Image("defaultAvatar")
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .shadow(radius: 6)
                        
                        Button(action: {
                            isPickerPresented = true
                        }) {
                            Label("사진 선택", systemImage: "photo")
                                .font(.subheadline)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color(.systemGray5))
                                .cornerRadius(20)
                        }
                    }
                    .padding(.top, 20)
                    
                    // 닉네임 섹션
                    VStack(alignment: .leading, spacing: 8) {
                        Text("닉네임")
                            .font(.headline)
                        TextField("새 닉네임을 입력하세요", text: $newNickname)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    // 자기소개(Bio) 섹션
                    VStack(alignment: .leading, spacing: 8) {
                        Text("자기소개")
                            .font(.headline)
                        TextField("자기소개를 입력하세요", text: $newBio)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    // 위치 섹션
                    VStack(alignment: .leading, spacing: 8) {
                        Text("위치")
                            .font(.headline)
                        TextField("거주지를 입력하세요", text: $newLocation)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)
                    
                    // 저장 버튼 섹션
                    VStack {
                        if isSaving {
                            ProgressView("저장 중...")
                                .frame(maxWidth: .infinity)
                        } else {
                            Button(action: {
                                saveProfileChanges()
                            }) {
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
                // 기존 프로필 정보를 초기화하여 편집 필드에 반영
                newNickname = profileViewModel.nickname
                newBio = profileViewModel.bio
                newLocation = profileViewModel.location
            }
            .sheet(isPresented: $isPickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .alert(isPresented: Binding<Bool>(
                get: { errorMessage != nil },
                set: { _ in errorMessage = nil }
            )) {
                Alert(title: Text("오류"), message: Text(errorMessage ?? ""), dismissButton: .default(Text("확인")))
            }
        }
    }
    
    func saveProfileChanges() {
        isSaving = true
        profileViewModel.updateNickname(newNickname: newNickname) { success in
            if !success {
                isSaving = false
                errorMessage = "닉네임 업데이트에 실패했습니다."
                return
            }
            profileViewModel.updateAdditionalInfo(newBio: newBio, newLocation: newLocation) { additionalSuccess in
                if !additionalSuccess {
                    isSaving = false
                    errorMessage = "추가 정보 업데이트에 실패했습니다."
                    return
                }
                if let image = selectedImage {
                    profileViewModel.updateProfilePicture(newImage: image) { result in
                        DispatchQueue.main.async {
                            isSaving = false
                            switch result {
                            case .success:
                                dismiss()
                            case .failure(let error):
                                errorMessage = error.localizedDescription
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
