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
                                // 추가 피드백 (예: 성공/실패 Alert)
                            }
                        }
                    
                    if viewModel.isUpdating {
                        ProgressView("업데이트 중...")
                            .padding(.top, 4)
                    }
                }
                
                Section(header: Text("계정 관리")) {
                    Button(action: {
                        // 계정 탈퇴 로직: 예를 들어 AuthService.deleteAccount() 호출 후 로그아웃 처리
                        viewModel.deleteAccount { success in
                            // 성공 시 로그인 뷰로 전환
                        }
                    }) {
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
                set: { newValue in if !newValue { viewModel.errorMessage = nil } }
            )) {
                Alert(title: Text("오류"),
                      message: Text(viewModel.errorMessage ?? ""),
                      dismissButton: .default(Text("확인")))
            }
        }
    }
}
