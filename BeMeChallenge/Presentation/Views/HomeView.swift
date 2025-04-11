// HomeView.swift
import SwiftUI

struct HomeView: View {
    @StateObject var challengeVM = ChallengeViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(challengeVM.challenges) { challenge in
                        ChallengeCardView(challenge: challenge)
                    }
                }
                .padding()
            }
            .navigationTitle("챌린지")
            .onAppear {
                challengeVM.fetchChallenges()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
