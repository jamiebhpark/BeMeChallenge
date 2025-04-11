// BlockedUsersView.swift
import SwiftUI

struct BlockedUsersView: View {
    @StateObject var viewModel = BlockedUsersViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.blockedUsers) { blockedUser in
                    HStack {
                        if let imageUrl = blockedUser.profilePictureURL, let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView().frame(width: 40, height: 40)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                case .failure:
                                    Image(systemName: "person.crop.circle")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                        Text(blockedUser.nickname)
                            .font(.headline)
                        Spacer()
                        Button("차단 해제") {
                            viewModel.unblockUser(userId: blockedUser.userId)
                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("차단된 사용자 목록")
            .onAppear {
                viewModel.loadBlockedUsers()
            }
        }
    }
}

struct BlockedUsersView_Previews: PreviewProvider {
    static var previews: some View {
        BlockedUsersView()
    }
}
