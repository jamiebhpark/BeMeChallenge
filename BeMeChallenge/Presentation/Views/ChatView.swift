// Presentation/Views/ChatView.swift
import SwiftUI

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel
    
    init(friendId: String) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(friendId: friendId))
    }
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.messages) { msg in
                            MessageRow(message: msg)
                        }
                    }
                    .padding()
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            HStack {
                TextField("메시지를 입력하세요...", text: $viewModel.newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    viewModel.sendMessage { success in
                        // 추가적인 피드백 처리(예: 실패 시 Alert) 가능
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
        .navigationTitle("채팅")
    }
}

struct MessageRow: View {
    var message: DirectMessage
    var isSentByCurrentUser: Bool {
        return message.senderId == Auth.auth().currentUser?.uid
    }
    
    var body: some View {
        HStack {
            if isSentByCurrentUser { Spacer() }
            Text(message.message)
                .padding()
                .background(isSentByCurrentUser ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                .cornerRadius(10)
                .id(message.id)
            if !isSentByCurrentUser { Spacer() }
        }
        .padding(.horizontal)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatView(friendId: "friendExampleId")
        }
    }
}
