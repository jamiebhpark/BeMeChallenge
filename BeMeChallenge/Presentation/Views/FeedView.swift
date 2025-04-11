// Presentation/Views/FeedView.swift
import SwiftUI

struct FeedView: View {
    @StateObject var viewModel = FeedViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.feedItems) { item in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.username)
                            .font(.headline)
                        Spacer()
                        if let date = item.createdAt {
                            Text(date, style: .time)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    Text(item.message)
                        .font(.body)
                }
                .padding(.vertical, 8)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Activity Feed")
            .onAppear {
                viewModel.fetchFeed()
            }
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
