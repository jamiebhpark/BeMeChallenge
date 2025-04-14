// CameraView.swift (업데이트)
import SwiftUI
import AVFoundation

struct CameraView: View {
    var challengeId: String
    @StateObject var cameraVM = CameraViewModel()
    @State private var showPhotoPreview = false

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
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
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
        .onChange(of: cameraVM.capturedImage) { newValue in
            if newValue != nil {
                showPhotoPreview = true
            }
        }
        // fullScreenCover 대신 sheet를 사용해보는 방법
        .sheet(isPresented: $showPhotoPreview) {
            PhotoPreviewView(cameraVM: cameraVM, challengeId: challengeId)
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView(challengeId: "sampleChallengeId")
    }
}
