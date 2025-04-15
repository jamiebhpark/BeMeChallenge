//  ProfileHeaderView.swift
import SwiftUI

struct ProfileHeaderView: View {
    @ObservedObject var viewModel: ProfileViewModel  // ProfileViewModel에서 사용자 정보를 가져옴

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // 프로필 이미지 영역
            if let urlString = viewModel.profileImageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 80, height: 80)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .shadow(radius: 4)
                    case .failure:
                        Image("defaultAvatar")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .shadow(radius: 4)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image("defaultAvatar")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 4)
            }
            
            // 사용자 정보 (닉네임, 가입일)
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.nickname)
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                Text("가입일: \(viewModel.joinDateString)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            
            // 프로필 편집 버튼
            NavigationLink(destination: ProfilePictureUpdateView()) {
                Image(systemName: "pencil.circle.fill")
                    .font(.title)
                    .foregroundColor(Color("PrimaryGradientEnd"))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct ProfileHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        // 미리보기용 더미 ProfileViewModel 인스턴스
        ProfileHeaderView(viewModel: ProfileViewModel())
            .previewLayout(.sizeThatFits)
    }
}
