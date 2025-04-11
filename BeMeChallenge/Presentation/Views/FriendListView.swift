// FriendListView.swift
import SwiftUI

struct FriendListView: View {
    @StateObject var viewModel = FriendListViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.friends) { friend in
                HStack {
                    if let imageUrl = friend.profilePictureURL, let url = URL(string: imageUrl) {
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
                    Text(friend.nickname)
                        .font(.headline)
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("친구 목록")
            .onAppear {
                viewModel.loadFriends()
            }
        }
    }
}

struct FriendListView_Previews: PreviewProvider {
    static var previews: some View {
        FriendListView()
    }
}
