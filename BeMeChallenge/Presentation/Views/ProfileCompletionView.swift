//ProfileCompletionView.swift
import SwiftUI

struct ProfileCompletionView: View {
    // 외부에서 ProfileViewModel 인스턴스를 주입받습니다.
    @ObservedObject var profileViewModel: ProfileViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("프로필 완성도")
                .font(.headline)
            
            ProgressView(value: profileViewModel.completionPercentage, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .padding(.horizontal)
            
            Text("당신의 프로필이 \(Int(profileViewModel.completionPercentage))% 완성되었습니다.")
                .font(.subheadline)
            
            if profileViewModel.completionPercentage < 100 {
                NavigationLink(destination: ProfileEditView(profileViewModel: profileViewModel)) {
                    Text("프로필 완성하기")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("프로필이 완성되었습니다.")
                        .foregroundColor(.green)
                        .font(.headline)
                }
                .padding()
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            // 필요시 추가 작업(리프레시 등) 수행
        }
        .alert(isPresented: Binding<Bool>(
            get: { profileViewModel.errorMessage != nil },
            set: { _ in profileViewModel.errorMessage = nil }
        )) {
            Alert(
                title: Text("오류"),
                message: Text(profileViewModel.errorMessage ?? ""),
                dismissButton: .default(Text("확인"))
            )
        }
    }
}
