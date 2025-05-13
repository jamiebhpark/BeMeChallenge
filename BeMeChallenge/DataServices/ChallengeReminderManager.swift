// ChallengeReminderManager.swift
import Foundation
import UserNotifications
import SwiftUI

class ChallengeReminderManager: ObservableObject {
    static let shared = ChallengeReminderManager()
    
    /// 주어진 챌린지에 대해 지정된 시간(reminderTime)에 알림(리마인더)을 스케줄링합니다.
    func scheduleReminder(for challenge: Challenge, reminderTime: Date) {
        // UNUserNotificationCenter에 알림 권한 요청 (권한이 아직 없는 경우)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("알림 권한 요청 에러: \(error.localizedDescription)")
                return
            }
            if !granted {
                print("알림 권한이 거부되었습니다.")
                return
            }
            
            // 알림 콘텐츠 생성
            let content = UNMutableNotificationContent()
            content.title = "챌린지 마감 임박!"
            content.body = "챌린지 '\(challenge.title)'의 마감 시간이 다가옵니다. 참여를 놓치지 마세요!"
            content.sound = .default
            
            // 트리거 생성: reminderTime의 연도, 월, 일, 시, 분 정보를 사용하여 예약
            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderTime)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            // Request 생성: 챌린지의 documentID를 알림의 식별자로 사용
            let request = UNNotificationRequest(identifier: challenge.id, content: content, trigger: trigger)
            
            // 알림 예약
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("알림 스케줄 에러: \(error.localizedDescription)")
                } else {
                    print("챌린지 '\(challenge.title)'에 대한 알림이 예약되었습니다.")
                }
            }
        }
    }
    
    /// 지정된 챌린지에 대해 예약된 알림을 취소합니다.
    func cancelReminder(for challenge: Challenge) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [challenge.id])
        print("챌린지 '\(challenge.title)'에 대한 알림이 취소되었습니다.")
    }
}
