//PhotoPreviewView.swift
import SwiftUI

// 업로드 알림을 위한 enum (성공/오류)
enum UploadAlert: Identifiable {
    case success(message: String)
    case error(message: String)
    
    var id: String {
        switch self {
        case .success(let message): return "success-\(message)"
        case .error(let message): return "error-\(message)"
        }
    }
}

struct PhotoPreviewView: View {
    @ObservedObject var cameraVM: CameraViewModel
    var challengeId: String
    
    // 로컬로 캡쳐된 이미지를 보존해 미리보기에 사용
    @State private var previewImage: UIImage? = nil
    @State private var isUploading: Bool = false
    @State private var alert: UploadAlert? = nil
    @State private var showSuccessAlert: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    // 업로드 성공 시 호출될 콜백 (CameraView 모달 전체 dismiss)
    var onUploadSuccess: (() -> Void)? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 미리보기 이미지 영역
                if let image = previewImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 500)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .padding(.horizontal, 20)
                } else {
                    Text("사진이 없습니다.")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // 버튼 영역
                HStack(spacing: 20) {
                    // "다시 찍기" 버튼
                    Button(action: {
                        previewImage = nil
                        cameraVM.capturedImage = nil
                        dismiss()  // PhotoPreviewView 닫고 촬영 화면으로 복귀
                    }) {
                        Text("다시 찍기")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
                    
                    // "지금 올리기" 버튼
                    Button(action: {
                        guard let image = previewImage else { return }
                        isUploading = true
                        cameraVM.uploadPhoto(image, forChallenge: challengeId) { result in
                            DispatchQueue.main.async {
                                isUploading = false
                                switch result {
                                case .success:
                                    showSuccessAlert = true
                                case .failure(let error):
                                    alert = .error(message: error.localizedDescription)
                                }
                            }
                        }
                    }) {
                        if isUploading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("지금 올리기")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color("Lavender"), Color("SkyBlue")]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .navigationTitle("사진 업로드")
            .navigationBarItems(leading: Button("취소") {
                dismiss()
            })
            .onAppear {
                // 미리보기 화면에 나타날 때 cameraVM.capturedImage 값을 local previewImage에 저장
                previewImage = cameraVM.capturedImage
            }
            .alert(item: $alert) { alertItem in
                switch alertItem {
                case .error(let message):
                    return Alert(
                        title: Text("업로드 오류"),
                        message: Text(message),
                        dismissButton: .default(Text("확인"))
                    )
                case .success(let message):
                    return Alert(
                        title: Text("업로드 성공"),
                        message: Text(message),
                        dismissButton: .default(Text("확인"), action: {
                            onUploadSuccess?()
                            dismiss()
                        })
                    )
                }
            }
            .alert(isPresented: $showSuccessAlert) {
                Alert(
                    title: Text("업로드 성공"),
                    message: Text("사진이 성공적으로 업로드되었습니다."),
                    dismissButton: .default(Text("확인"), action: {
                        onUploadSuccess?()
                        dismiss()
                    })
                )
            }
        }
    }
}
