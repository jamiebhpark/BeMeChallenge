// BlockedUsersViewModel.swift
import Foundation
import Combine

class BlockedUsersViewModel: ObservableObject {
    @Published var blockedUsers: [BlockedUser] = []
    
    func loadBlockedUsers() {
        FriendBlockService.shared.fetchBlockedUsers { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self.blockedUsers = users
                case .failure(let error):
                    print("친구 차단 목록 로드 에러: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func unblockUser(userId: String) {
        FriendBlockService.shared.unblockUser(userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.loadBlockedUsers()
                case .failure(let error):
                    print("친구 차단 해제 에러: \(error.localizedDescription)")
                }
            }
        }
    }
}
