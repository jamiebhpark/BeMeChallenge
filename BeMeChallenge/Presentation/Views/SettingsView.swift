// Presentation/Views/SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @StateObject var settingsVM = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                // Profile Section
                Section(header: Text("프로필 정보")) {
                    HStack {
                        Image("defaultAvatar")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                        VStack(alignment: .leading) {
                            Text(settingsVM.nickname)
                                .font(.headline)
                            Button("프로필 사진 변경") {
                                // 프로필 사진 변경 액션 구현 예정
                            }
                        }
                    }
                    TextField("닉네임", text: $settingsVM.nickname)
                        .autocapitalization(.none)
                    Button("닉네임 업데이트") {
                        settingsVM.updateNickname()
                    }
                }
                
                // Legal Section
                Section(header: Text("법적 정보")) {
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Text("개인정보 처리방침")
                    }
                }
                
                // Account Section
                Section {
                    Button("계정 삭제") {
                        settingsVM.deleteAccount()
                    }
                    .foregroundColor(.red)
                    
                    Button("로그아웃") {
                        settingsVM.signOut()
                    }
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("설정")
            .onAppear {
                settingsVM.fetchUserProfile()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
