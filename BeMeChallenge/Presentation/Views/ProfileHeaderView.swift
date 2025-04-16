// ProfileHeaderView.swift
// ProfileHeaderView.swift
import SwiftUI

struct ProfileHeaderView: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // 프로필 이미지: AsyncImage 사용, 없을 경우 기본 이미지 표시
            if let urlString = viewModel.profileImageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView().frame(width: 80, height: 80)
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
            
            // 사용자 정보: 닉네임과 참여 횟수를 뱃지로 표시
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.nickname)
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                
                // 참여 횟수 표시: 아이콘 + 배경 캡슐 사용
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.white)
                        .font(.caption)
                        .padding(4)
                        .background(Circle().fill(Color("PrimaryGradientEnd")))
                    Text("\(viewModel.calendarViewModel.participationDates.count) 회 참여")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Capsule().fill(Color("PrimaryGradientEnd")))
                }
            }
            
            Spacer()
            
            // 프로필 편집 버튼 (ProfileEditView로 내비게이션)
            NavigationLink(destination: ProfileEditView(profileViewModel: viewModel)) {
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
