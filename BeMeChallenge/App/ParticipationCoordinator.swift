//  ParticipationCoordinator.swift

import SwiftUI

class ParticipationCoordinator: ObservableObject {
    @Published var activeChallengeId: String? = nil
    @Published var showCameraView: Bool = false

    func startParticipation(for challengeId: String) {
        activeChallengeId = challengeId
        showCameraView = true
    }

    func endParticipation() {
        activeChallengeId = nil
        showCameraView = false
    }
}
