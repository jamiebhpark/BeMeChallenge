// FavoritesView.swift
import SwiftUI

struct FavoritesView: View {
    @StateObject var viewModel = FavoritesViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.favorites) { favorite in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("ID: \(favorite.itemId)")
                                .font(.headline)
                            Text("Type: \(favorite.type)")
                                .font(.subheadline)
                        }
                        Spacer()
                        Button(action: {
                            viewModel.removeFavorite(itemId: favorite.itemId, type: favorite.type)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("즐겨찾기")
            .onAppear {
                viewModel.loadFavorites()
            }
            .alert(item: Binding.constant(viewModel.errorMessage ?? "")) { error in
                Alert(title: Text("오류"), message: Text(error), dismissButton: .default(Text("확인")))
            }
        }
    }
}

extension String: Identifiable {
    public var id: String { self }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
    }
}
