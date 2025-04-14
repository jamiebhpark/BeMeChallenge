import SwiftUI

struct ProfilePictureUpdateView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedImage: UIImage?
    @State private var isPickerPresented = false
    @State private var isUploading = false
    @State private var uploadError: String?
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .padding()
            } else {
                Image("defaultAvatar")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .padding()
            }
            
            Button("프로필 사진 선택") {
                isPickerPresented = true
            }
            .padding()
            
            if isUploading {
                ProgressView("업로드 중...")
                    .padding()
            }
            
            Button("사진 업데이트") {
                guard let image = selectedImage else { return }
                isUploading = true
                viewModel.updateProfilePicture(newImage: image) { result in
                    DispatchQueue.main.async {
                        isUploading = false
                        switch result {
                        case .success:
                            presentationMode.wrappedValue.dismiss()
                        case .failure(let error):
                            uploadError = error.localizedDescription
                        }
                    }
                }
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("프로필 사진 변경")
        .sheet(isPresented: $isPickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .alert(isPresented: Binding<Bool>(
            get: { uploadError != nil },
            set: { newValue in if !newValue { uploadError = nil } }
        )) {
            Alert(title: Text("업로드 오류"),
                  message: Text(uploadError ?? ""),
                  dismissButton: .default(Text("확인")))
        }
    }
}

struct ProfilePictureUpdateView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfilePictureUpdateView()
        }
    }
}
