import SwiftUI

struct ProfilePrivacyView: View {
    @StateObject var viewModel = ProfilePrivacyViewModel()
    @State private var isUpdating = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("프로필 공개 설정")) {
                    Toggle("프로필 공개", isOn: $viewModel.isProfilePublic)
                        .onChange(of: viewModel.isProfilePublic) { newValue in
                            isUpdating = true
                            viewModel.updatePrivacySetting(to: newValue) { success in
                                DispatchQueue.main.async {
                                    isUpdating = false
                                }
                            }
                        }
                    
                    if isUpdating {
                        ProgressView("업데이트 중...")
                            .padding(.top, 4)
                    }
                }
            }
            .navigationTitle("프로필 개인정보")
            .onAppear {
                viewModel.fetchPrivacySetting()
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

struct ProfilePrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePrivacyView()
    }
}
