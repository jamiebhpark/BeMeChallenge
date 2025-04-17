// FeedbackView.swift
import SwiftUI

struct FeedbackView: View {
    @StateObject var viewModel = FeedbackViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastColor: Color = .green

    var body: some View {
        ZStack(alignment: .top) {
            // 1) 그룹드 배경
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            // 2) 흰색 카드 스타일 콘텐츠
            VStack(spacing: 16) {
                SectionHeader(title: "피드백 보내기")

                TextEditor(text: $viewModel.message)
                    .frame(height: 180)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                Spacer()

                Button("제출하기", action: submit)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("PrimaryGradientEnd"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 1)
            .padding(.horizontal)

            // 3) 토스트 메시지
            if showToast {
                Text(toastMessage)
                    .font(.subheadline).bold()
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(toastColor)
                    .cornerRadius(8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
                    .padding(.top, 16)
            }
        }
        .onTapGesture { hideKeyboard() }
    }

    private func submit() {
        viewModel.submitFeedback { success in
            toastMessage = success
                ? "제출이 완료되었습니다!"
                : (viewModel.errorMessage ?? "제출에 실패했습니다.")
            toastColor = success ? .green : .red

            withAnimation { showToast = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation { showToast = false }
                if success { dismiss() }
            }
        }
    }
}

// MARK: - Keyboard Dismiss Helper
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}
#endif

