//ProfilePrivacyView.swift
import SwiftUI

struct ProfilePrivacyView: View {
  @StateObject private var notificationVM = NotificationSettingsViewModel()
  @EnvironmentObject private var authViewModel: AuthViewModel

  var body: some View {
    Form {
      Section(header: Text("알림 설정")) {
        Toggle("푸시 알림 받기", isOn: $notificationVM.isPushEnabled)
          .onChange(of: notificationVM.isPushEnabled) {
            notificationVM.togglePush($0)
          }
        if notificationVM.isUpdating {
          ProgressView("반영 중…")
        }
      }
      .listRowBackground(Color(.systemBackground))
      .cornerRadius(12)

      Section(header: Text("계정 관리")) {
        NavigationLink {
          AccountDeletionView()
            .environmentObject(authViewModel)
        } label: {
          Text("계정 삭제")
            .foregroundColor(.red)
        }
      }
      .listRowBackground(Color(.systemBackground))
      .cornerRadius(12)
    }
    // Form/List 기본 배경 숨기고 그룹드 배경을 드러냅니다
    .scrollContentBackground(.hidden)
    .background(Color(.systemGroupedBackground))
    .onAppear {
      notificationVM.fetchNotificationSettings()
    }
    // 에러 알림
    .alert(
      "알림 권한 안내",
      isPresented: Binding<Bool>(
        get: { notificationVM.errorMessage != nil },
        set: { if !$0 { notificationVM.errorMessage = nil } }
      )
    ) {
      Button("확인", role: .cancel) {}
    } message: {
      Text(notificationVM.errorMessage ?? "")
    }
  }
}

