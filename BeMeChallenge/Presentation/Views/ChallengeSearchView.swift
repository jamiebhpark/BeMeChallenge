// ChallengeSearchView.swift
import SwiftUI

struct ChallengeSearchView: View {
    @StateObject var viewModel = ChallengeSearchViewModel()
    @StateObject var challengeVM = ChallengeViewModel() // 공유 인스턴스
    @StateObject var participationCoordinator = ParticipationCoordinator() // 추가: 참여 코디네이터

    var body: some View {
        NavigationView {
            VStack {
                TextField("챌린지 검색...", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                if viewModel.filteredChallenges.isEmpty {
                    Text("검색 결과가 없습니다.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(viewModel.filteredChallenges) { challenge in
                        NavigationLink(destination: ChallengeDetailView(challengeId: challenge.id)) {
                            // participationCoordinator를 함께 전달
                            ChallengeCardView(challenge: challenge, viewModel: challengeVM, participationCoordinator: participationCoordinator)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                Spacer()
            }
            .navigationTitle("챌린지 검색")
        }
    }
}
