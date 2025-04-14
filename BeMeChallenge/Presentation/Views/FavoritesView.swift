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
            .alert(isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { newValue in if !newValue { viewModel.errorMessage = nil } }
            )) {
                Alert(title: Text("오류"),
                      message: Text(viewModel.errorMessage ?? ""),
                      dismissButton: .default(Text("확인")))
            }
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
    }
}
