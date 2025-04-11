// Presentation/Views/DailyChallengeView.swift
import SwiftUI

struct DailyChallengeView: View {
    @StateObject var viewModel = DailyChallengeViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let challenge = viewModel.dailyChallenge {
                    // 챌린지 이미지 (이미지 URL이 제공되면 AsyncImage 활용)
                    if let imageUrl = challenge.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView().frame(height: 200)
                            case .success(let image):
                                image.resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .clipped()
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    Text(challenge.title)
                        .font(.title)
                        .fontWeight(.bold)
                    Text(challenge.description)
                        .font(.body)
                        .padding()
                    
                    Button(action: {
                        // 챌린지 참여 로직: 예를 들어 ChallengeDetailView로 내비게이션 등
                        print("오늘의 챌린지에 참여합니다.")
                    }) {
                        Text("오늘의 챌린지 참여하기")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                } else if let error = viewModel.errorMessage {
                    Text("오류: \(error)")
                        .foregroundColor(.red)
                } else {
                    ProgressView("오늘의 챌린지를 불러오는 중...")
                }
                
                Spacer()
            }
            .navigationTitle("오늘의 챌린지")
        }
        .onAppear {
            viewModel.fetchTodayChallenge()
        }
    }
}

struct DailyChallengeView_Previews: PreviewProvider {
    static var previews: some View {
        DailyChallengeView()
    }
}
