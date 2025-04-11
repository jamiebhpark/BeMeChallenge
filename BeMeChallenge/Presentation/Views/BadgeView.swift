// BadgeView.swift
import SwiftUI

struct BadgeView: View {
    @StateObject var viewModel = BadgeViewModel()
    
    // 3열 그리드 레이아웃 정의
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.badges) { badge in
                        VStack {
                            AsyncImage(url: URL(string: badge.imageUrl)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 80, height: 80)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                case .failure:
                                    Image(systemName: "star")
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            Text(badge.name)
                                .font(.caption)
                                .fontWeight(.semibold)
                            if badge.earned {
                                Text("획득")
                                    .foregroundColor(.green)
                                    .font(.caption2)
                            } else {
                                Text("미획득")
                                    .foregroundColor(.gray)
                                    .font(.caption2)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 2)
                    }
                }
                .padding()
            }
            .navigationTitle("뱃지")
            .onAppear {
                viewModel.loadUserBadges()
            }
        }
    }
}

struct BadgeView_Previews: PreviewProvider {
    static var previews: some View {
        BadgeView()
    }
}
