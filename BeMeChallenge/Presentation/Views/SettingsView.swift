//  SettingsView.swift
//  BeMeChallenge
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("개인정보")) {
                    NavigationLink("개인정보 설정") {
                        ProfilePrivacyView()
                            .environmentObject(authViewModel)
                    }
                }

                Section(header: Text("지원")) {
                    NavigationLink("앱 정보", destination: AboutView())
                    NavigationLink("도움말 & FAQ", destination: HelpFAQView())
                    NavigationLink("피드백 보내기", destination: FeedbackView())
                }

                Section {
                    Button("로그아웃", role: .destructive) {
                        authViewModel.signOut()
                        dismiss()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("닫기") { dismiss() }
                }
            }
        }
    }
}
