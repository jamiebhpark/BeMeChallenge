// Presentation/ViewModels/SupportChatViewModel.swift
import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class SupportChatViewModel: ObservableObject {
    @Published var messages: [SupportChatMessage] = []
    @Published var newMessage: String = ""
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    var challengeId: String
    
    init(challengeId: String) {
        self.challengeId = challengeId
        fetchMessages()
    }
    
    /// Firestore에서 현재 챌린지의 응원 메시지를 실시간으로 조회합니다.
    func fetchMessages() {
        listener?.remove()
        listener = db.collection("challenges")
            .document(challengeId)
            .collection("supportChat")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("응원 메시지 조회 에러: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                let fetchedMessages: [SupportChatMessage] = documents.compactMap { doc in
                    try? doc.data(as: SupportChatMessage.self)
                }
                DispatchQueue.main.async {
                    self?.messages = fetchedMessages
                }
            }
    }
    
    /// 사용자가 작성한 응원 메시지를 Firestore에 전송합니다.
    func sendMessage() {
        let trimmedMessage = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        let messageData: [String: Any] = [
            "message": trimmedMessage,
            "createdAt": FieldValue.serverTimestamp()
        ]
        db.collection("challenges")
            .document(challengeId)
            .collection("supportChat")
            .addDocument(data: messageData) { error in
                if let error = error {
                    print("응원 메시지 전송 에러: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        self.newMessage = ""
                    }
                }
            }
    }
    
    deinit {
        listener?.remove()
    }
}
