// Presentation/Home/HomeView.swift
import SwiftUI

// ——— String을 Identifiable로 확장 ———
extension String: @retroactive Identifiable {
    public var id: String { self }
}

struct HomeView: View {
    @StateObject private var vm   = ChallengeViewModel()
    @StateObject private var camC = CameraCoordinator()
    @State private var selectedType: ChallengeType = .mandatory

    var body: some View {
        VStack {
            Picker("챌린지 타입", selection: $selectedType) {
                Text(ChallengeType.mandatory.rawValue)
                    .tag(ChallengeType.mandatory)
                Text(ChallengeType.open.rawValue)
                    .tag(ChallengeType.open)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(vm.challenges.filter { $0.type == selectedType }) { ch in
                        ChallengeCardView(challenge: ch, viewModel: vm)
                            .environmentObject(camC)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("챌린지")
        // CameraCoordinator.currentChallengeID: String?
        .fullScreenCover(item: $camC.currentChallengeID) { challengeID in
            CameraView(challengeId: challengeID) {
                camC.dismiss()
            }
        }
    }
}
