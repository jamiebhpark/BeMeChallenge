// ProfileHeaderView.swift
import SwiftUI

struct ProfileHeaderView: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color("PrimaryGradientStart"), Color("PrimaryGradientEnd")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .cornerRadius(16)
            .shadow(radius: 4)

            HStack(spacing: 16) {
                // 1) Avatar (effective URL)
                if let url = viewModel.profileImageUpdatedAt != nil
                            ? URL(string: "\(viewModel.profileImageURL!)?v=\(Int(viewModel.profileImageUpdatedAt!))")
                            : URL(string: viewModel.profileImageURL ?? "")
                {
                    AsyncCachedImage(
                        url: url,
                        content: { $0.resizable() },
                        placeholder: { Image("defaultAvatar").resizable() },
                        failure:     { Image("defaultAvatar").resizable() }
                    )
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                } else {
                    Image("defaultAvatar")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }

                // 2) 닉네임 & 참여 횟수
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.nickname)
                        .font(.title2).bold()
                        .foregroundColor(.white)
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        Text("\(viewModel.calendarViewModel.participationDates.count)회 참여")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                Spacer()
                Image(systemName: "pencil")
                    .font(.title3)
                    .foregroundColor(.white)
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
    }
}
