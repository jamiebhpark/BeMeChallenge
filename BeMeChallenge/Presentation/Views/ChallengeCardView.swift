// Presentation/Views/ChallengeCardView.swift
import SwiftUI

struct ChallengeCardView: View {
    let challenge: Challenge
    @ObservedObject var viewModel: ChallengeViewModel
    let participationCoordinator: ParticipationCoordinator

    @State private var showDuplicateAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 1) 타입 뱃지
            Text(challenge.type.rawValue)
                .font(.caption2).bold()
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(
                    Group {
                        if challenge.type == .mandatory {
                            LinearGradient(
                                colors: [Color("Lavender"), Color("SkyBlue")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            Color.clear
                        }
                    }
                )
                .overlay(
                    Capsule()
                        .stroke(Color("Lavender"),
                                lineWidth: challenge.type == .open ? 1 : 0)
                )
                .foregroundColor(
                    challenge.type == .mandatory ? .white : Color("Lavender")
                )
                .clipShape(Capsule())

            // 2) 상세 링크
            NavigationLink(destination: ChallengeDetailView(challengeId: challenge.id)) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(challenge.title).font(.headline)
                    Text(challenge.description).font(.subheadline)
                    HStack {
                        Text("참여자: \(challenge.participantsCount)")
                        Spacer()
                        Text(challenge.endDate, formatter: DateFormatter.shortDate)
                    }
                    .font(.caption)
                }
            }

            // 3) 참여 버튼 (mandatory는 하루 1회만)
            if challenge.type == .mandatory
               && viewModel.todayParticipations.contains(challenge.id) {
                // 이미 오늘 참여한 상태: 비활성화된 버튼
                Button {
                    showDuplicateAlert = true
                } label: {
                    Text("오늘 이미 참여하셨습니다")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.3))
                        .foregroundColor(.gray)
                        .cornerRadius(10)
                }
            } else {
                // 참여 가능
                Button {
                    joinChallenge()
                } label: {
                    Text(challenge.type == .mandatory ? "오늘 참여하기" : "참여하기")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [Color("Lavender"), Color("SkyBlue")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 4)
        .alert("알림", isPresented: $showDuplicateAlert) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("해당 챌린지에 이미 참여한 상태입니다.")
        }
    }

    private func joinChallenge() {
        viewModel.joinChallenge(challenge: challenge) { result in
            switch result {
            case .success:
                participationCoordinator.startParticipation(for: challenge.id)
            case .failure:
                showDuplicateAlert = true
            }
        }
    }
}

extension DateFormatter {
    static var shortDate: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .short
        return f
    }
}
