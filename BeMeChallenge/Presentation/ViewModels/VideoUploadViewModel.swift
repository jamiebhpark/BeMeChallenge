import Foundation
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class VideoUploadViewModel: ObservableObject {
    private let storage = Storage.storage()
    private let db = Firestore.firestore()
    
    /// 비디오를 Firebase Storage에 업로드하고, 업로드 후 Firestore에 게시물 기록을 생성합니다.
    func uploadVideo(videoURL: URL, forChallenge challengeId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "VideoUpload", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자를 찾을 수 없습니다."])))
            return
        }
        let fileName = UUID().uuidString + ".mov" // 비디오 형식에 맞게 확장자 선택
        let storageRef = storage.reference().child("user_uploads/\(userId)/\(challengeId)/\(fileName)")
        
        storageRef.putFile(from: videoURL, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let downloadURL = url else {
                    completion(.failure(NSError(domain: "VideoUpload", code: -1, userInfo: [NSLocalizedDescriptionKey: "다운로드 URL 생성 실패"])))
                    return
                }
                self.saveVideoPost(forChallenge: challengeId, videoURL: downloadURL, completion: completion)
            }
        }
    }
    
    private func saveVideoPost(forChallenge challengeId: String, videoURL: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "VideoUpload", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자를 찾을 수 없습니다."])))
            return
        }
        let newPost: [String: Any] = [
            "challengeId": challengeId,
            "userId": userId,
            "videoUrl": videoURL.absoluteString,
            "createdAt": FieldValue.serverTimestamp(),
            "reactions": [:],
            "reported": false,
            "mediaType": "video"
        ]
        db.collection("challengePosts").addDocument(data: newPost) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
