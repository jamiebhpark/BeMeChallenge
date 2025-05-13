// Presentation/Features/Camera/PhotoPreviewView.swift
import SwiftUI

struct PhotoPreviewView: View {
    @ObservedObject var cameraVM: CameraViewModel
    let challengeId: String
    let onUploadSuccess: () -> Void

    @Environment(\.dismiss)         private var dismiss
    @EnvironmentObject private var modalC: ModalCoordinator

    @State private var previewImage: UIImage? = nil

    // ▶️ 업로드 중인지 여부 계산 프로퍼티
    private var isUploading: Bool {
        if case .running = cameraVM.uploadState { return true }
        return false
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // ── 미리보기 ────────────────────────
                if let img = previewImage {
                    Image(uiImage: img)
                        .resizable().scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 440)
                        .cornerRadius(16).shadow(radius: 6)
                        .padding(.horizontal, 20)
                } else {
                    Text("사진이 없습니다.")
                        .font(.title3).foregroundColor(.secondary)
                }

                // ── 업로드 진행률 ────────────────────
                if case .running(let pct) = cameraVM.uploadState {
                    ProgressView(value: pct)
                        .progressViewStyle(.linear)
                        .padding(.horizontal, 40)
                }

                Spacer()

                // ── 버튼 영역 ───────────────────────
                HStack(spacing: 16) {
                    retryButton
                    uploadButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .navigationTitle("사진 업로드")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") { dismiss() }
                }
            }
            .onAppear { previewImage = cameraVM.capturedImage }
        }
    }

    // MARK: – Buttons
    private var retryButton: some View {
        Button {
            cameraVM.capturedImage = nil
            dismiss()
        } label: {
            Text("다시 찍기")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray5))
                .clipShape(Capsule())
        }
    }

    private var uploadButton: some View {
        Button { startUpload() } label: {
            Group {
                switch cameraVM.uploadState {
                case .running:
                    EmptyView() // 상단 ProgressView로 충분
                case .succeeded:
                    Image(systemName: "checkmark")
                        .font(.title3).bold()
                default:
                    Text("지금 올리기").bold()
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
        }
        .background(
            LinearGradient(
                colors: [Color("Lavender"), Color("SkyBlue")],
                startPoint: .leading, endPoint: .trailing
            )
        )
        .clipShape(Capsule())
        .disabled(isUploading)
    }

    // MARK: – Upload Handler
    private func startUpload() {
        guard previewImage != nil else { return }
        cameraVM.startUpload(forChallenge: challengeId) { success in
            if success {
                modalC.showToast(ToastItem(message: "업로드 완료"))
                onUploadSuccess()
            } else {
                let msg: String
                if case .failed(let err) = cameraVM.uploadState {
                    msg = err.localizedDescription
                } else {
                    msg = "업로드 실패"
                }
                modalC.showToast(ToastItem(message: msg))
            }
        }
    }
}
