// CameraView.swift (업데이트)
import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject var cameraVM = CameraViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // 카메라 프리뷰
                CameraPreview(session: cameraVM.session)
                    .onAppear {
                        cameraVM.configureSession()
                    }
                    .onDisappear {
                        cameraVM.stopSession()
                    }
                
                // 촬영 버튼
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            cameraVM.capturePhoto()
                        }) {
                            Circle()
                                .strokeBorder(Color.white, lineWidth: 4)
                                .frame(width: 80, height: 80)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 30)
                }
                
                // capturedImage가 존재하면 미리보기 화면으로 내비게이션
                if cameraVM.capturedImage != nil {
                    NavigationLink(
                        destination: PhotoPreviewView(cameraVM: cameraVM, challengeId: "exampleChallengeId"),
                        isActive: .constant(true),
                        label: {
                            EmptyView()
                        })
                        .hidden()
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
