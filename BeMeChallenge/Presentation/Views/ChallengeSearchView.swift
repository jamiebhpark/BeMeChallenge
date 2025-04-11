// ChallengeSearchView.swift
import SwiftUI

struct ChallengeSearchView: View {
    @StateObject var viewModel = ChallengeSearchViewModel()
    
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
                            ChallengeCardView(challenge: challenge)
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

struct ChallengeSearchView_Previews: PreviewProvider {
    static var previews: some View {
        ChallengeSearchView()
    }
}
