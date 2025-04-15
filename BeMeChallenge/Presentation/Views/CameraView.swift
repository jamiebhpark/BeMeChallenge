// CameraView.swift (업데이트)
import SwiftUI
import AVFoundation

struct CameraView: View {
    var challengeId: String
    @StateObject var cameraVM = CameraViewModel()
    @State private var showPhotoPreview = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            CameraPreview(session: cameraVM.session)
                .onAppear {
                    // 백그라운드 스레드에서 startRunning 호출
                    DispatchQueue.global(qos: .userInitiated).async {
                        cameraVM.configureSession()
                    }
                }
                .onDisappear {
                    cameraVM.stopSession()
                }
            
            // 상단 취소 버튼
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 16)
                    .padding(.top, 50)
                    Spacer()
                }
                Spacer()
            }
            
            // 하단 촬영 버튼
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        print("촬영 버튼 눌림")
                        cameraVM.capturePhoto()
                    }) {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                            )
                    }
                    Spacer()
                }
                .padding(.bottom, 30)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onChange(of: cameraVM.capturedImage) { newValue in
            if newValue != nil {
                showPhotoPreview = true
            }
        }
        // fullScreenCover 호출 시, onUploadSuccess 클로저를 전달합니다.
        .fullScreenCover(isPresented: $showPhotoPreview) {
            PhotoPreviewView(cameraVM: cameraVM, challengeId: challengeId, onUploadSuccess: {
                dismiss()
            })
        }
    }
}

