// ChallengeShareView.swift
import SwiftUI

struct ChallengeShareView: View {
    var challenge: Challenge
    @State private var isShareSheetPresented = false
    @State private var shareURL: URL?
    @State private var isLoadingLink = false
    
    var body: some View {
        VStack {
            Button(action: {
                isLoadingLink = true
                DynamicLinksManager.shared.generateDynamicLink(forChallenge: challenge.id) { url in
                    DispatchQueue.main.async {
                        self.isLoadingLink = false
                        if let generatedURL = url {
                            self.shareURL = generatedURL
                            self.isShareSheetPresented = true
                        } else {
                            print("동적 링크 생성 실패")
                        }
                    }
                }
            }, label: {
                HStack {
                    if isLoadingLink {
                        ProgressView()
                    } else {
                        Image(systemName: "square.and.arrow.up")
                        Text("챌린지 공유하기")
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color("Lavender"), Color("SkyBlue")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(8)
            })
            .padding()
            .sheet(isPresented: $isShareSheetPresented) {
                if let url = shareURL {
                    ActivityView(activityItems: [url])
                }
            }
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // 필요 시 업데이트 로직 작성
    }
}

struct ChallengeShareView_Previews: PreviewProvider {
    static var previews: some View {
        // 샘플 챌린지 데이터를 사용한 미리보기
        let sampleChallenge = Challenge(
            id: "1",
            title: "오늘의 도전",
            description: "샘플 챌린지입니다.",
            participantsCount: 50,
            endDate: Date()
        )
        ChallengeShareView(challenge: sampleChallenge)
            .previewLayout(.sizeThatFits)
    }
}
