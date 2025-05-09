// StreakView.swift
import SwiftUI

struct StreakView: View {
    let totalParticipations: Int
    let streakDays: Int

    var body: some View {
        HStack(spacing: 0) {
            // 왼쪽: 총 참여
            VStack(spacing: 4) {
                Text("총 참여")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("\(totalParticipations)회")
                    .font(.title2).bold()
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)

            Divider()
                .frame(height: 48)
                .padding(.horizontal, 8)

            // 오른쪽: 연속 참여
            VStack(spacing: 4) {
                Text("연속 참여")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("\(streakDays)일")
                    .font(.title2).bold()
                    .foregroundColor(Color("PrimaryGradientStart"))
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}
