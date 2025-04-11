// FriendSearchView.swift
import SwiftUI

struct FriendSearchView: View {
    @State private var searchText: String = ""
    @State private var searchResults: [Friend] = []
    @State private var requestStatusMessage: String?
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("친구 닉네임 검색...", text: $searchText, onCommit: {
                    searchFriends()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                
                if !searchResults.isEmpty {
                    List(searchResults) { friend in
                        HStack {
                            Text(friend.nickname)
                                .font(.body)
                            Spacer()
                            Button("요청 보내기") {
                                sendFriendRequest(to: friend.userId)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .padding(.vertical, 4)
                    }
                } else {
                    Text("검색 결과가 없습니다.")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                if let status = requestStatusMessage {
                    Text(status)
                        .foregroundColor(.green)
                        .padding()
                }
                
                Spacer()
            }
            .navigationTitle("친구 검색")
        }
    }
    
    func searchFriends() {
        FriendService.shared.searchFriends(byNickname: searchText) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let friends):
                    self.searchResults = friends
                case .failure(let error):
                    print("친구 검색 에러: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func sendFriendRequest(to friendUserId: String) {
        FriendService.shared.sendFriendRequest(to: friendUserId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    requestStatusMessage = "친구 요청이 전송되었습니다."
                case .failure(let error):
                    requestStatusMessage = "요청 실패: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct FriendSearchView_Previews: PreviewProvider {
    static var previews: some View {
        FriendSearchView()
    }
}
