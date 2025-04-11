// Presentation/Views/SponsoredChallengesView.swift
import SwiftUI

struct SponsoredChallengesView: View {
    @StateObject var viewModel = SponsoredChallengeViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.sponsoredChallenges) { challenge in
                NavigationLink(destination: ChallengeDetailView(challengeId: challenge.id ?? "")) {
                    HStack(spacing: 12) {
                        AsyncImage(url: URL(string: challenge.imageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 60, height: 60)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipped()
                                    .cornerRadius(8)
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(challenge.title)
                                .font(.headline)
                            Text("by \(challenge.sponsorName)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("스폰서 챌린지")
            .onAppear {
                viewModel.fetchSponsoredChallenges()
            }
        }
    }
}

struct SponsoredChallengesView_Previews: PreviewProvider {
    static var previews: some View {
        SponsoredChallengesView()
    }
}
