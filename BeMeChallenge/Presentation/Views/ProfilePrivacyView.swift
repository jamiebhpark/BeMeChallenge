//ProfilePrivacyView.swift
import SwiftUI

struct ProfilePrivacyView: View {
    @StateObject var viewModel = ProfilePrivacyViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("프로필 공개 설정")) {
                    Toggle("프로필 공개", isOn: $viewModel.isProfilePublic)
                        .onChange(of: viewModel.isProfilePublic) { newValue in
                            viewModel.updatePrivacySetting(to: newValue) { success in
                                // 추가 피드백 처리 가능
                            }
                        }
                    if viewModel.isUpdating {
                        ProgressView("업데이트 중...")
                            .padding(.top, 4)
                    }
                }
                
                Section(header: Text("계정 관리")) {
                    // 계정 삭제 내비게이션 버튼를 추가합니다.
                    NavigationLink(destination: AccountDeletionView().environmentObject(AuthService.shared)) {
                        Text("계정 삭제")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("프로필 개인정보")
            .onAppear {
                viewModel.fetchPrivacySetting()
            }
            .alert(isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { _ in viewModel.errorMessage = nil }
            )) {
                Alert(title: Text("오류"),
                      message: Text(viewModel.errorMessage ?? ""),
                      dismissButton: .default(Text("확인")))
            }
        }
    }
}
