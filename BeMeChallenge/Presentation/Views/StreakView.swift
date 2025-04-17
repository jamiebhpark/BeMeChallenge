//  StreakView.swift
import SwiftUI

struct StreakView: View {
    @StateObject private var vm = StreakViewModel()

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .font(.headline)
                .foregroundColor(Color("PrimaryGradientEnd"))
            VStack(alignment: .leading, spacing: 2) {
                Text("\(vm.currentStreak)일 연속 참여 중!")
                    .font(.subheadline).fontWeight(.semibold)
                Text("꾸준히 달성하고 있어요")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .onAppear {
            vm.fetchAndCalculateStreak()
        }
    }
}
