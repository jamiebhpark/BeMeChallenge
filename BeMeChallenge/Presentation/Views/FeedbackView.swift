// FeedbackView.swift
import SwiftUI

struct FeedbackView: View {
    @StateObject var viewModel = FeedbackViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("피드백을 작성해 주세요:")
                    .font(.headline)
                    .padding(.horizontal)
                
                TextEditor(text: $viewModel.message)
                    .border(Color.gray.opacity(0.5), width: 1)
                    .frame(height: 200)
                    .padding(.horizontal)
                
                if let errorMsg = viewModel.errorMessage {
                    Text(errorMsg)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.submitFeedback { success in
                        if success {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }) {
                    Text("피드백 제출")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            .padding(.top)
            .navigationTitle("피드백")
        }
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
    }
}
