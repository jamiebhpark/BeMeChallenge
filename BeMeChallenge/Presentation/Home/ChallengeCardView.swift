// Presentation/Home/ChallengeCardView.swift
import SwiftUI
import Combine

struct ChallengeCardView: View {
    let challenge: Challenge
    @ObservedObject var viewModel: ChallengeViewModel
    @EnvironmentObject private var camC: CameraCoordinator
    @State private var cancellables = Set<AnyCancellable>()
    @State private var showDuplicateAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 1) 타입 뱃지
            Text(challenge.type.rawValue)
                .font(.caption2).bold()
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background {
                    if challenge.type == .mandatory {
                        LinearGradient(
                            colors: [Color("Lavender"), Color("SkyBlue")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                }
                .overlay(
                    Capsule()
                        .stroke(Color("Lavender"),
                                lineWidth: challenge.type == .open ? 1 : 0)
                )
                .foregroundColor(
                    challenge.type == .mandatory ? .white : Color("Lavender")
                )
                .clipShape(Capsule())

            // 2) 상세 화면으로 네비게이트 (destination-based)
            NavigationLink {
                ChallengeDetailView(challengeId: challenge.id)
            } label: {
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

            // 3) 참여 버튼
            if challenge.type == .mandatory,
               viewModel.todayParticipations.contains(challenge.id) {
                Button { showDuplicateAlert = true } label: {
                    Text("오늘 이미 참여하셨습니다")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.3))
                        .foregroundColor(.gray)
                        .cornerRadius(10)
                }
            } else {
                Button { joinChallenge() } label: {
                    Text(challenge.type == .mandatory ? "오늘 참여하기" : "참여하기")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background {
                            LinearGradient(
                                colors: [Color("Lavender"), Color("SkyBlue")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        }
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
        let cid = challenge.id
        viewModel.participate(in: challenge)
            .sink { completion in
                if case .failure = completion {
                    showDuplicateAlert = true
                }
            } receiveValue: { _ in
                camC.presentCamera(for: cid)
            }
            .store(in: &cancellables)
    }
}

// 날짜 포맷터 재사용
extension DateFormatter {
    static var shortDate: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .short
        return f
    }
}
