// CameraView.swift (업데이트)
import SwiftUI
import AVFoundation

struct CameraView: View {
    var challengeId: String
    var onFinish: () -> Void                 // ✅ 완료 콜백
    
    @StateObject var cameraVM = CameraViewModel()
    @State private var showPhotoPreview = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            CameraPreview(session: cameraVM.session)
                .onAppear {
                    DispatchQueue.global(qos: .userInitiated).async {
                        cameraVM.configureSession()
                    }
                }
                .onDisappear { cameraVM.stopSession() }
            
            cancelButton
            shutterButton
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onChange(of: cameraVM.capturedImage) { _ in
            showPhotoPreview = cameraVM.capturedImage != nil
        }
        .fullScreenCover(isPresented: $showPhotoPreview) {
            PhotoPreviewView(
                cameraVM: cameraVM,
                challengeId: challengeId
            ) {
                // 업로드 성공 → 두 단계 모두 닫기
                dismiss()          // PhotoPreview 닫기
                onFinish()         // CameraCoordinator dismiss
            }
        }
    }
    
    // MARK: – Sub-UI
    private var cancelButton: some View {
        VStack {
            HStack {
                Button { dismiss(); onFinish() } label: {
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
    }
    
    private var shutterButton: some View {
        VStack {
            Spacer()
            Button { cameraVM.capturePhoto() } label: {
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
            }
            .padding(.bottom, 30)
        }
    }
}
