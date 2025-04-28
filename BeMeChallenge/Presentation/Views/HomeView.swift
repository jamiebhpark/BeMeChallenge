// Presentation/Views/HomeView.swift
import SwiftUI

struct HomeView: View {
  @StateObject private var vm = ChallengeViewModel()
  @StateObject private var coord = ParticipationCoordinator()
  @State private var selectedType: ChallengeType = .mandatory

  var body: some View {
    NavigationView {
      VStack {
        // 1) 상단 탭 (필수 / 오픈)
        Picker("챌린지 타입", selection: $selectedType) {
          Text(ChallengeType.mandatory.rawValue).tag(ChallengeType.mandatory)
          Text(ChallengeType.open.rawValue).tag(ChallengeType.open)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)

        // 2) 선택된 타입에 맞춰 ChallengeCardView 나열
        ScrollView {
          LazyVStack(spacing: 16) {
            ForEach(vm.challenges.filter { $0.type == selectedType }) { ch in
              ChallengeCardView(
                challenge: ch,
                viewModel: vm,
                participationCoordinator: coord
              )
            }
          }
          .padding()
        }
      }
      .navigationTitle("챌린지")
    }
    // CameraView 모달 띄우기
    .fullScreenCover(isPresented: $coord.showCameraView) {
      if let id = coord.activeChallengeId {
        CameraView(challengeId: id)
      }
    }
    .onAppear {
      vm.fetchChallenges()
    }
  }
}
