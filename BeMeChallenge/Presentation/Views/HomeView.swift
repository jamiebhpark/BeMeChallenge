// HomeView.swift
import SwiftUI

struct HomeView: View {
    @StateObject var challengeVM = ChallengeViewModel()
    @StateObject var participationCoordinator = ParticipationCoordinator()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(challengeVM.challenges) { challenge in
                        // ChallengeCardView에 participationCoordinator 전달
                        ChallengeCardView(challenge: challenge, viewModel: challengeVM, participationCoordinator: participationCoordinator)
                    }
                }
                .padding()
            }
            .navigationTitle("챌린지")
            .onAppear {
                challengeVM.fetchChallenges()
            }
        }
        // HomeView가 MainTabView 내에 있을 때 모달로 CameraView를 띄웁니다.
        .fullScreenCover(isPresented: $participationCoordinator.showCameraView) {
            if let challengeId = participationCoordinator.activeChallengeId {
                CameraView(challengeId: challengeId)
            } else {
                EmptyView()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

