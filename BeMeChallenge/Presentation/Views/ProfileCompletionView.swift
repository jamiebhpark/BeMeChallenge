//ProfileCompletionView.swift
import SwiftUI

struct ProfileCompletionView: View {
    @ObservedObject var profileViewModel: ProfileViewModel

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("프로필 완성도")
                    .font(.headline)
                Spacer()
                Text("\(Int(profileViewModel.completionPercentage))%")
                    .font(.subheadline).bold()
            }

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemGray5))
                    .frame(height: 8)
                Capsule()
                    .fill(LinearGradient(
                        colors: [Color("PrimaryGradientStart"), Color("PrimaryGradientEnd")],
                        startPoint: .leading, endPoint: .trailing
                    ))
                    .frame(width: CGFloat(profileViewModel.completionPercentage / 100) * UIScreen.main.bounds.width * 0.8,
                           height: 8)
            }

            if profileViewModel.completionPercentage < 100 {
                NavigationLink(destination: ProfileEditView(profileViewModel: profileViewModel)) {
                    Text("프로필 완성하기")
                        .font(.subheadline)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(Color("PrimaryGradientStart"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                    Text("완료됨")
                        .foregroundColor(.green)
                        .font(.subheadline).bold()
                }
            }
        }
        .padding()
    }
}
