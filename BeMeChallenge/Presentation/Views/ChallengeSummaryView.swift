// ChallengeSummaryView.swift
import SwiftUI

struct ChallengeSummaryView: View {
    var challengeId: String
    @StateObject var viewModel = ChallengeSummaryViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                if let summary = viewModel.summary {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("총 게시물 수: \(summary.totalPosts)")
                            .font(.headline)
                        ForEach(summary.totalReactions.keys.sorted(), id: \.self) { emoji in
                            HStack {
                                Text("\(emoji) 총합: \(summary.totalReactions[emoji] ?? 0)")
                                Spacer()
                                Text(String(format: "평균: %.1f", summary.averageReactions[emoji] ?? 0))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                } else if let error = viewModel.errorMessage {
                    Text("에러: \(error)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    ProgressView("요약 정보를 불러오는 중...")
                        .padding()
                }
                Spacer()
            }
            .navigationTitle("챌린지 결과")
            .onAppear {
                viewModel.fetchSummary(for: challengeId)
            }
        }
    }
}

struct ChallengeSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        ChallengeSummaryView(challengeId: "exampleChallengeId")
    }
}
