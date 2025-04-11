// ChallengeReminderView.swift
import SwiftUI

struct ChallengeReminderView: View {
    var challenge: Challenge
    @State private var reminderTime: Date = Date()
    @State private var isReminderScheduled = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("챌린지: \(challenge.title)")
                    .font(.headline)
                    .padding(.top)
                
                DatePicker("알림 받을 시간 선택", selection: $reminderTime, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                
                HStack(spacing: 16) {
                    Button(action: {
                        // 알림 예약 취소
                        ChallengeReminderManager.shared.cancelReminder(for: challenge)
                        isReminderScheduled = false
                        alertMessage = "알림이 취소되었습니다."
                        showAlert = true
                    }) {
                        Text("알림 취소")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        // 알림 예약
                        ChallengeReminderManager.shared.scheduleReminder(for: challenge, reminderTime: reminderTime)
                        isReminderScheduled = true
                        alertMessage = "알림이 예약되었습니다."
                        showAlert = true
                    }) {
                        Text("알림 예약")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                
                if isReminderScheduled {
                    Text("현재 예약된 알림: \(reminderTime.formatted(date: .abbreviated, time: .shortened))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Spacer()
            }
            .navigationTitle("챌린지 알림 예약")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("알림 상태"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
            }
        }
    }
}

struct ChallengeReminderView_Previews: PreviewProvider {
    static var previews: some View {
        // 샘플 챌린지 데이터를 사용한 미리보기
        let sampleChallenge = Challenge(
            id: "challenge1",
            title: "오늘의 출근룩",
            description: "자연스러운 출근 복장 공유",
            participantsCount: 100,
            endDate: Date().addingTimeInterval(3600 * 24)
        )
        ChallengeReminderView(challenge: sampleChallenge)
    }
}
