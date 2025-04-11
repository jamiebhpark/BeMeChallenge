// Presentation/Views/ChallengeReviewView.swift
import SwiftUI

struct ChallengeReviewView: View {
    var challengeId: String
    @StateObject var viewModel = ChallengeReviewViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // 평균 평점 표시
                HStack {
                    Text("평균 평점: \(String(format: "%.1f", viewModel.averageRating))")
                        .font(.headline)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                // 후기 리스트
                List(viewModel.reviews) { review in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            ForEach(1..<6) { star in
                                Image(systemName: star <= review.rating ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                            }
                        }
                        Text(review.reviewText)
                            .font(.body)
                        if let date = review.createdAt {
                            Text(date, style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(PlainListStyle())
                
                Divider()
                    .padding(.vertical, 8)
                
                // 후기 작성 폼
                VStack(spacing: 8) {
                    Text("나의 후기 작성")
                        .font(.headline)
                    
                    // 평점 입력 (별 입력)
                    HStack {
                        ForEach(1..<6) { star in
                            Image(systemName: star <= viewModel.userRating ? "star.fill" : "star")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.yellow)
                                .onTapGesture {
                                    viewModel.userRating = star
                                }
                        }
                    }
                    
                    TextField("후기를 입력하세요", text: $viewModel.userReviewText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: {
                        viewModel.submitReview(for: challengeId) { success in
                            // 성공/실패 처리 필요 시 추가
                        }
                    }) {
                        Text("후기 제출")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("챌린지 후기")
            .onAppear {
                viewModel.fetchReviews(for: challengeId)
            }
        }
    }
}

struct ChallengeReviewView_Previews: PreviewProvider {
    static var previews: some View {
        ChallengeReviewView(challengeId: "exampleChallengeId")
    }
}
