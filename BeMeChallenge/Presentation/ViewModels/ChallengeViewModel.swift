// Presentation/ViewModels/ChallengeViewModel.swift
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
    private var listener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init / Deinit
    init() { fetchChallenges() ; fetchTodayParticipations() }
    deinit { listener?.remove() }
    
    // MARK: - Public API
    
    /// UI 가 직접 구독하는 배열 프로퍼티
    var challenges: [Challenge] { challengesState.value ?? [] }
    
    /// 챌린지 참여 - 결과는 Combine 의 `Result` 스트림으로 반환
    func participate(in challenge: Challenge) -> AnyPublisher<Void,Error> {
        Future { [weak self] promise in
            guard let self, let uid = Auth.auth().currentUser?.uid else {
                return promise(.failure(NSError(domain:"Auth", code:-1)))
            }
            self.performJoin(uid: uid, challenge: challenge, promise: promise)
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Private helpers
    
    private func fetchChallenges() {
        challengesState = .loading
        listener = db.collection("challenges")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snap, err in
                guard let self else { return }
                if let err = err { self.challengesState = .failed(err); return }
                let list = snap?.documents.compactMap(Challenge.init) ?? []
                self.challengesState = .loaded(list)
            }
    }
    
    private func fetchTodayParticipations() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let startOfDay = Calendar.current.startOfDay(for: Date())
        db.collection("users").document(uid)
            .collection("participations")
            .whereField("date", isGreaterThanOrEqualTo: startOfDay)
            .addSnapshotListener { [weak self] snap, _ in
                let ids = snap?.documents
                    .compactMap { $0.data()["challengeId"] as? String } ?? []
                self?.todayParticipations = Set(ids)
            }
    }
    
    private func performJoin(uid: String,
                             challenge: Challenge,
                             promise: @escaping (Result<Void,Error>) -> Void) {
        // ⚡️ 하루 1회 제한 체크 제거 → 이미 todayParticipations 에 포함돼 있으면 early fail
        if challenge.type == .mandatory, todayParticipations.contains(challenge.id) {
            promise(.failure(NSError(domain:"Challenge", code:0,
                                     userInfo:[NSLocalizedDescriptionKey:"이미 참여"])))
            return
        }
        let challengeRef = db.collection("challenges").document(challenge.id)
        challengeRef.updateData(["participantsCount": FieldValue.increment(Int64(1))]) { [weak self] err in
            if let err { return promise(.failure(err)) }
            self?.appendParticipationDoc(uid: uid, challengeID: challenge.id, promise: promise)
        }
    }
    
    private func appendParticipationDoc(uid: String,
                                        challengeID: String,
                                        promise: @escaping (Result<Void,Error>) -> Void) {
        db.collection("users").document(uid)
          .collection("participations").addDocument(data: [
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
