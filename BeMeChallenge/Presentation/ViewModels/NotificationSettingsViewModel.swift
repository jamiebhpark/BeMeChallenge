// Presentation/ViewModels/NotificationSettingsViewModel.swift
import Foundation
import UserNotifications
import UIKit

/// Settings 화면의 “푸시 알림 받기” 토글 로직 담당
class NotificationSettingsViewModel: ObservableObject {
    @Published var isPushEnabled: Bool = false
    @Published var isUpdating: Bool = false
    @Published var errorMessage: String? = nil

    init() {
        fetchNotificationSettings()
    }

    /// 현재 시스템 알림 권한 상태 조회
    func fetchNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                let stat = settings.authorizationStatus
                self?.isPushEnabled = (stat == .authorized || stat == .provisional)
            }
        }
    }

    /// 토글 on/off 처리
    func togglePush(_ enabled: Bool) {
        if enabled {
            isUpdating = true
            UNUserNotificationCenter.current()
              .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
                DispatchQueue.main.async {
                  self?.isUpdating = false
                  if let e = error {
                    self?.errorMessage = e.localizedDescription
                    self?.isPushEnabled = false
                  } else if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                    self?.isPushEnabled = true
                  } else {
                    self?.isPushEnabled = false
                  }
                }
            }
        } else {
            // iOS 에서는 앱 내에서 권한 철회 불가 → 설정 앱 안내
            errorMessage = "푸시 알림 해제는 기기 설정 → BeMe Challenge → 알림에서 가능합니다."
            fetchNotificationSettings()
        }
    }
}
