import SwiftUI

struct ProfileCompletionView: View {
    @StateObject var viewModel = ProfileCompletionViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("프로필 완성도")
                .font(.headline)
            
            ProgressView(value: viewModel.completionPercentage, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .padding(.horizontal)
            
            Text("당신의 프로필이 \(Int(viewModel.completionPercentage))% 완성되었습니다.")
                .font(.subheadline)
            
            Button(action: {
                // 프로필 편집 화면으로의 내비게이션 구현 (예: ProfileEditView 전환)
                print("프로필 편집 화면으로 이동")
            }) {
                Text("프로필 완성하기")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.fetchUserProfileCompletion()
        }
        .alert(isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { newValue in if !newValue { viewModel.errorMessage = nil } }
        )) {
            Alert(title: Text("오류"),
                  message: Text(viewModel.errorMessage ?? ""),
                  dismissButton: .default(Text("확인")))
        }
    }
}

struct ProfileCompletionView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileCompletionView()
    }
}
