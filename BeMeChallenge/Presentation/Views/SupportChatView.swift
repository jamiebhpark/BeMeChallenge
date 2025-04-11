// Presentation/Views/SupportChatView.swift
import SwiftUI

struct SupportChatView: View {
    @StateObject var viewModel: SupportChatViewModel
    
    init(challengeId: String) {
        _viewModel = StateObject(wrappedValue: SupportChatViewModel(challengeId: challengeId))
    }
    
    var body: some View {
        VStack {
            // 메시지 리스트
            List(viewModel.messages) { message in
                VStack(alignment: .leading) {
                    Text(message.message)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    Text(message.createdAt, style: .time)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
            .listStyle(PlainListStyle())
            
            // 메시지 입력 및 전송
            HStack {
                TextField("응원 메시지를 입력하세요", text: $viewModel.newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    viewModel.sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
        .navigationTitle("응원 방")
    }
}

struct SupportChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SupportChatView(challengeId: "exampleChallengeId")
        }
    }
}
