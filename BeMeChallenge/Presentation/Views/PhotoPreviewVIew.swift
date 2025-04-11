// PhotoPreviewView.swift
import SwiftUI

struct PhotoPreviewView: View {
    @ObservedObject var cameraVM: CameraViewModel
    var challengeId: String // 업로드할 챌린지 ID
    
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
                    // 다시 찍기: capturedImage 초기화 → 카메라 화면으로 복귀
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
                                // 업로드 성공 후 상태 초기화 또는 성공 메시지 표시
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
        .alert(item: $uploadError) { error in
            Alert(title: Text("업로드 오류"), message: Text(error), dismissButton: .default(Text("확인")))
        }
    }
}

// String을 Identifiable로 확장(Alert용)
extension String: Identifiable {
    public var id: String { self }
}

struct PhotoPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = CameraViewModel()
        vm.capturedImage = UIImage(systemName: "photo")
        return PhotoPreviewView(cameraVM: vm, challengeId: "exampleChallengeId")
            .previewLayout(.sizeThatFits)
    }
}
