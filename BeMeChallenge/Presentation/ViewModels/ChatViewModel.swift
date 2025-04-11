// Presentation/ViewModels/ChatViewModel.swift
import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [DirectMessage] = []
    @Published var newMessage: String = ""
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    let friendId: String
    
    // conversationId를 계산: 두 사용자 ID를 오름차순으로 합침 ("min_friendId_max_friendId")
    var conversationId: String {
        guard let currentId = Auth.auth().currentUser?.uid else { return friendId }
        return currentId < friendId ? "\(currentId)_\(friendId)" : "\(friendId)_\(currentId)"
    }
    
    init(friendId: String) {
        self.friendId = friendId
        fetchMessages()
    }
    
    func fetchMessages() {
        listener?.remove()
        listener = db.collection("directMessages")
            .whereField("conversationId", isEqualTo: conversationId)
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("메시지 조회 에러: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                let msgs = documents.compactMap { doc -> DirectMessage? in
                    try? doc.data(as: DirectMessage.self)
                }
                DispatchQueue.main.async {
                    self?.messages = msgs
                }
            }
    }
    
    func sendMessage(completion: @escaping (Bool) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid,
              !newMessage.trimmingCharacters(in: .whitespaces).isEmpty else {
            completion(false)
            return
        }
        
        let messageData: [String: Any] = [
            "conversationId": conversationId,
            "senderId": currentUserId,
            "receiverId": friendId,
            "message": newMessage,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("directMessages").addDocument(data: messageData) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("메시지 전송 에러: \(error.localizedDescription)")
                    completion(false)
                } else {
                    self?.newMessage = ""
                    completion(true)
                }
            }
        }
    }
    
    deinit {
        listener?.remove()
    }
}
