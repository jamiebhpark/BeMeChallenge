// Presentation/Views/ContactSupportView.swift
import SwiftUI
import MessageUI

struct ContactSupportView: View {
    @State private var isShowingMailView = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    @State private var showMailErrorAlert = false
    
    var body: some View {
        VStack {
            Text("문의 사항이나 지원 요청이 있으시면, 아래 버튼을 통해 이메일을 보내주세요.")
                .padding()
            
            Button("이메일 보내기") {
                if MFMailComposeViewController.canSendMail() {
                    isShowingMailView = true
                } else {
                    showMailErrorAlert = true
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .navigationTitle("문의하기")
        .sheet(isPresented: $isShowingMailView) {
            MailView(result: $mailResult)
        }
        .alert(isPresented: $showMailErrorAlert) {
            Alert(title: Text("메일 사용 불가"), message: Text("이 기기에서 이메일을 보낼 수 없습니다. Mail 앱을 이용해 주세요."), dismissButton: .default(Text("확인")))
        }
    }
}

struct ContactSupportView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContactSupportView()
        }
    }
}

// MailView.swift : MFMailComposeViewController를 SwiftUI에 연동하기 위한 래퍼
struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation
    @Binding var result: Result<MFMailComposeResult, Error>?
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var presentation: PresentationMode
        @Binding var result: Result<MFMailComposeResult, Error>?
        
        init(presentation: Binding<PresentationMode>, result: Binding<Result<MFMailComposeResult, Error>?>) {
            _presentation = presentation
            _result = result
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer { $presentation.wrappedValue.dismiss() }
            if let error = error {
                self.result = .failure(error)
                return
            }
            self.result = .success(result)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: presentation, result: $result)
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients(["support@bemechallenge.com"]) // 실제 지원 이메일로 변경
        vc.setSubject("BeMe Challenge 지원 문의")
        vc.setMessageBody("문의 내용을 여기에 작성해 주세요.", isHTML: false)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) { }
}
