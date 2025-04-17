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
                // Avatar with white border
                if let url = URL(string: viewModel.profileImageURL ?? "") {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img): img.resizable()
                        default: Image("defaultAvatar").resizable()
                        }
                    }
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
                NavigationLink(destination: ProfileEditView(profileViewModel: viewModel)) {
                    Image(systemName: "pencil")
                        .foregroundColor(.white)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
    }
}
