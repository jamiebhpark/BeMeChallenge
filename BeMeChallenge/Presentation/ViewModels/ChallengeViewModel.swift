// Presentation/ViewModels/ChallengeViewModel.swift
import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
final class ChallengeViewModel: ObservableObject {
    // 전체 챌린지
    @Published var challenges: [Challenge] = []
    // 중복 참여 방지 (전체)
    @Published var participatedChallenges: Set<String> = []
    // 오늘(00:00 이후) 참여한 챌린지만 따로 관리
    @Published var todayParticipations: Set<String> = []

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init() {
        fetchChallenges()
        fetchParticipatedChallenges()
        fetchTodayParticipations()
    }

    deinit {
        listener?.remove()
    }

    /// 전체 챌린지 로드
    func fetchChallenges() {
        listener = db.collection("challenges")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snap, err in
                guard let self = self else { return }
                if let err = err {
                    print("Error fetching challenges:", err.localizedDescription)
                    return
                }
                self.challenges = snap?.documents.compactMap(Challenge.init) ?? []
            }
    }

    /// 전체 참여 기록(중복 방지) 로드
    private func fetchParticipatedChallenges() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users")
            .document(uid)
            .collection("participations")
            .getDocuments { [weak self] snap, _ in
                guard let docs = snap?.documents else { return }
                DispatchQueue.main.async {
                    self?.participatedChallenges = Set(docs.map { $0.documentID })
                }
            }
    }

    /// 오늘(00:00 이후) 참여 기록만 로드
    private func fetchTodayParticipations() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let startOfDay = Calendar.current.startOfDay(for: Date())
        db.collection("users")
            .document(uid)
            .collection("participations")
            .whereField("date", isGreaterThanOrEqualTo: startOfDay)
            .getDocuments { [weak self] snap, _ in
                guard let docs = snap?.documents else { return }
                let ids = docs.compactMap { $0.data()["challengeId"] as? String }
                DispatchQueue.main.async {
                    self?.todayParticipations = Set(ids)
                }
            }
    }

    /// 챌린지 참여 (필수는 하루 1회, 오픈은 무제한)
    func joinChallenge(challenge: Challenge,
                       completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            let e = NSError(domain: "Auth", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "로그인이 필요합니다."])
            return completion(.failure(e))
        }

        // 필수 챌린지: 오늘 참여 여부 먼저 체크
        if challenge.type == .mandatory {
            let startOfDay = Calendar.current.startOfDay(for: Date())
            db.collection("users")
                .document(uid)
                .collection("participations")
                .whereField("challengeId", isEqualTo: challenge.id)
                .whereField("date", isGreaterThanOrEqualTo: startOfDay)
                .getDocuments { [weak self] snap, err in
                    if let err = err {
                        return completion(.failure(err))
                    }
                    if let count = snap?.documents.count, count > 0 {
                        let e = NSError(domain: "ChallengeViewModel", code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "오늘 이미 참여하셨습니다."])
                        completion(.failure(e))
                    } else {
                        self?.performJoin(challengeId: challenge.id, uid: uid, completion: completion)
                    }
                }
        } else {
            // 오픈 챌린지: 즉시 참여
            performJoin(challengeId: challenge.id, uid: uid, completion: completion)
        }
    }

    /// 실제 Firestore 업데이트 + 참여 기록 추가
    private func performJoin(challengeId: String,
                             uid: String,
                             completion: @escaping (Result<Void, Error>) -> Void) {
        let challengeRef = db.collection("challenges").document(challengeId)
        challengeRef.updateData([
            "participantsCount": FieldValue.increment(Int64(1))
        ]) { [weak self] err in
            if let err = err {
                return completion(.failure(err))
            }
            // participation 문서는 auto-ID로 생성 (오픈은 여러 번)
            let newDoc = self?.db.collection("users")
                .document(uid)
                .collection("participations")
                .document()
            newDoc?.setData([
                "challengeId": challengeId,
                "date": FieldValue.serverTimestamp()
            ]) { err in
                if let err = err {
                    completion(.failure(err))
                } else {
                    // 로컬 상태 반영
                    DispatchQueue.main.async {
                        self?.participatedChallenges.insert(challengeId)
                        self?.todayParticipations.insert(challengeId)
                    }
                    completion(.success(()))
                }
            }
        }
    }
}
