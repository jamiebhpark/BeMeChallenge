//PhotoPreviewView.swift
import SwiftUI

struct PhotoPreviewView: View {
    @ObservedObject var cameraVM: CameraViewModel
    var challengeId: String
    
    @State private var isUploading: Bool = false
    @State private var uploadError: String?
    
    var body: some View {
        VStack {
            if let image = cameraVM.capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 400)
                    .clipped()
            } else {
                Text("No image captured.")
            }
            
            HStack(spacing: 16) {
                Button(action: {
                    cameraVM.capturedImage = nil
                }) {
                    Text("다시 찍기")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                Button(action: {
                    guard let image = cameraVM.capturedImage else { return }
                    isUploading = true
                    cameraVM.uploadPhoto(image, forChallenge: challengeId) { result in
                        DispatchQueue.main.async {
                            isUploading = false
                            switch result {
                            case .success:
                                cameraVM.capturedImage = nil
                            case .failure(let error):
                                uploadError = error.localizedDescription
                            }
                        }
                    }
                }) {
                    if isUploading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("지금 올리기")
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                }
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()
        }
        .padding()
        .navigationTitle("사진 업로드")
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

struct PhotoPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = CameraViewModel()
        vm.capturedImage = UIImage(systemName: "photo")
        return PhotoPreviewView(cameraVM: vm, challengeId: "exampleChallengeId")
            .previewLayout(.sizeThatFits)
    }
}
