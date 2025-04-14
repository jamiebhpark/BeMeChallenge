// ChallengeSearchView.swift
import SwiftUI

struct ChallengeSearchView: View {
    @StateObject var viewModel = ChallengeSearchViewModel()
    @StateObject var challengeVM = ChallengeViewModel() // 추가: 챌린지 뷰모델 인스턴스 공유
    
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
                            // 공유된 challengeVM 인스턴스를 전달합니다.
                            ChallengeCardView(challenge: challenge, viewModel: challengeVM)
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
