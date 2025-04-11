// FriendListViewModel.swift
import Foundation
import Combine

class FriendListViewModel: ObservableObject {
    @Published var friends: [Friend] = []
    
    func loadFriends() {
        FriendService.shared.fetchFriendList { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let friendList):
                    self.friends = friendList
                case .failure(let error):
                    print("친구 목록 로드 에러: \(error.localizedDescription)")
                }
            }
        }
    }
}
