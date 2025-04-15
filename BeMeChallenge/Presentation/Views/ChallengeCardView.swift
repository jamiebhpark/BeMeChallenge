// Presentation/Views/ChallengeCardView.swift (업데이트 버전)
import SwiftUI

struct ChallengeCardView: View {
    var challenge: Challenge
    @ObservedObject var viewModel: ChallengeViewModel
    var participationCoordinator: ParticipationCoordinator
    
    // 중복 참여 시 알림을 위해 local alert 상태 추가
    @State private var showDuplicateAlert: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 카드의 상단 영역은 NavigationLink로 상세 화면 전환
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
                }
            }
            // "참여하기" 버튼: 누르면 참여 로직을 실행한 후, 중복 참여인 경우 알림 표시
            Button(action: {
                viewModel.joinChallenge(challengeId: challenge.id) { result in
                    switch result {
                    case .success:
                        participationCoordinator.startParticipation(for: challenge.id)
                    case .failure(let error):
                        if error.localizedDescription == "이미 참여하셨습니다." {
                            showDuplicateAlert = true
                        } else {
                            print("챌린지 참여 실패: \(error.localizedDescription)")
                        }
                    }
                }
            }) {
                Text("참여하기")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color("Lavender"), Color("SkyBlue")]),
                                       startPoint: .leading,
                                       endPoint: .trailing)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 4)
        .alert(isPresented: $showDuplicateAlert) {
            Alert(title: Text("이미 참여하셨습니다"), message: Text("해당 챌린지에 이미 참여한 상태입니다."), dismissButton: .default(Text("확인")))
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
