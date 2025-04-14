// Presentation/Views/ChallengeCardView.swift (업데이트 버전)
import SwiftUI

struct ChallengeCardView: View {
    var challenge: Challenge
    @ObservedObject var viewModel: ChallengeViewModel
    
    var body: some View {
        NavigationLink(destination: ChallengeDetailView(challengeId: challenge.id)) {
            VStack(alignment: .leading, spacing: 8) {
                Text(challenge.title)
                    .font(.headline)
                Text(challenge.description)
                    .font(.subheadline)
                HStack {
                    Text("참여자: \(challenge.participantsCount)")
                    Spacer()
                    Text("종료: \(challenge.endDate, formatter: DateFormatter.shortDate)")
                }
                .font(.caption)
                Button(action: {
                    // 참여하기 버튼 액션 (이전에는 별도의 내비게이션 로직 없이 UI만 존재)
                }) {
                    Text("참여하기")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [Color("Lavender"), Color("SkyBlue")]),
                                                   startPoint: .leading,
                                                   endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 4)
        }
    }
}

extension DateFormatter {
    static var shortDate: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}

struct ChallengeCardView_Previews: PreviewProvider {
    static var previews: some View {
        ChallengeCardView(challenge: Challenge(id: "1",
                                               title: "오늘의 출근룩",
                                               description: "자연스러운 출근 복장 공유",
                                               participantsCount: 120,
                                               endDate: Date()),
                           viewModel: ChallengeViewModel())
            .previewLayout(.sizeThatFits)
    }
}
