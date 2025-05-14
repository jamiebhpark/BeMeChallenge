//
//  ChallengeViewModel.swift
//  BeMeChallenge
//
//  개선 사항
//  1. 로그인/로그아웃 브로드캐스트(didSignIn · didSignOut) 대응
//  2. Firestore 리스너 2개(challenges · participations) 수명 제어
//  3. 로그아웃 시 리스너 해제, 재로그인 시 재구독
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
final class ChallengeViewModel: ObservableObject {

    // MARK: - Published
    @Published private(set) var challengesState: Loadable<[Challenge]> = .idle
    @Published private(set) var todayParticipations: Set<String> = []

    // MARK: - Private
    private let db = Firestore.firestore()
    private var challengeListener: ListenerRegistration?
    private var participationListener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init / Deinit
    init() {
        startListeners()

        NotificationCenter.default.publisher(for: .didSignOut)
            .sink { [weak self] _ in
                Task { @MainActor in self?.stopListeners() }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: .didSignIn)
            .sink { [weak self] _ in
                Task { @MainActor in self?.startListeners() }
            }
            .store(in: &cancellables)
    }

    // MARK: - Public API
    var challenges: [Challenge] { challengesState.value ?? [] }

    func participate(in challenge: Challenge) -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            guard let self,
                  let uid = Auth.auth().currentUser?.uid else {
                return promise(.failure(NSError(domain: "Auth", code: -1)))
            }
            self.performJoin(uid: uid, challenge: challenge, promise: promise)
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Listener 관리
    private func startListeners() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        // 챌린지 목록
        challengesState = .loading
        challengeListener = db.collection("challenges")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snap, err in
                if let err { self?.challengesState = .failed(err); return }
                let list = snap?.documents.compactMap(Challenge.init) ?? []
                self?.challengesState = .loaded(list)
            }

        // 오늘 참여
        let startOfDay = Calendar.current.startOfDay(for: Date())
        participationListener = db.collection("users").document(uid)
            .collection("participations")
            .whereField("date", isGreaterThanOrEqualTo: startOfDay)
            .addSnapshotListener { [weak self] snap, _ in
                let ids = snap?.documents.compactMap {
                    $0.data()["challengeId"] as? String
                } ?? []
                self?.todayParticipations = Set(ids)
            }
    }

    private func stopListeners() {
        challengeListener?.remove();      challengeListener = nil
        participationListener?.remove();  participationListener = nil
        challengesState = .idle
        todayParticipations.removeAll()
    }

    // MARK: - Participate Helpers
    private func performJoin(uid: String,
                             challenge: Challenge,
                             promise: @escaping (Result<Void, Error>) -> Void) {

        if challenge.type == .mandatory,
           todayParticipations.contains(challenge.id) {
            return promise(.failure(NSError(domain: "Challenge",
                                            code: 0,
                                            userInfo: [NSLocalizedDescriptionKey: "이미 참여"])))
        }

        let chRef = db.collection("challenges").document(challenge.id)
        chRef.updateData(["participantsCount": FieldValue.increment(Int64(1))]) { [weak self] err in
            if let err { return promise(.failure(err)) }
            self?.appendParticipationDoc(uid: uid,
                                         challengeID: challenge.id,
                                         promise: promise)
        }
    }

    private func appendParticipationDoc(uid: String,
                                        challengeID: String,
                                        promise: @escaping (Result<Void, Error>) -> Void) {
        db.collection("users").document(uid)
            .collection("participations")
            .addDocument(data: [
                "challengeId": challengeID,
                "date": FieldValue.serverTimestamp()
            ]) { [weak self] err in
                if let err { promise(.failure(err)) }
                else {
                    self?.todayParticipations.insert(challengeID)
                    promise(.success(()))
                }
            }
    }
}
