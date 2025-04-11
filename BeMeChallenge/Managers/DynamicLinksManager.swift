import FirebaseDynamicLinks
import UIKit

class DynamicLinksManager {
    static let shared = DynamicLinksManager()

    /// 주어진 챌린지 ID에 대해 동적 링크를 생성합니다.
    /// - Parameters:
    ///   - challengeId: 공유할 챌린지의 ID
    ///   - completion: 생성된 짧은 URL이 반환됩니다. 실패 시 nil.
    func generateDynamicLink(forChallenge challengeId: String, completion: @escaping (URL?) -> Void) {
        // 기본 링크: 웹 URL로 챌린지 페이지를 지정합니다.
        guard let link = URL(string: "https://bemechallenge.com/challenge/\(challengeId)") else {
            completion(nil)
            return
        }
        
        // 도메인 URI Prefix는 Firebase Console에서 설정한 값을 사용합니다.
        let dynamicLinksDomainURIPrefix = "https://bemechallenge.page.link"
        guard let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix) else {
            completion(nil)
            return
        }
        
        // iOS 파라미터 설정: 번들ID와 App Store ID를 지정합니다.
        linkBuilder.iOSParameters = DynamicLinkIOSParameters(bundleID: Bundle.main.bundleIdentifier!)
        linkBuilder.iOSParameters?.appStoreID = "123456789" // 실제 App Store ID로 교체하세요.
        
        // (선택 사항) 소셜 메타 태그 파라미터 설정: 공유 시 미리보기로 보여질 정보
        let socialParams = DynamicLinkSocialMetaTagParameters()
        socialParams.title = "BeMe Challenge"
        socialParams.descriptionText = "이 챌린지에 참여해보세요! 진짜 일상을 나누는 새로운 방식."
        socialParams.imageURL = URL(string: "https://example.com/path/to/challenge/image.png") // 실제 이미지 URL로 교체
        linkBuilder.socialMetaTagParameters = socialParams
        
        // 동적 링크를 단축(short) URL로 변환합니다.
        linkBuilder.shorten { shortURL, warnings, error in
            if let error = error {
                print("Dynamic Link 생성 오류: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let warnings = warnings {
                for warning in warnings {
                    print("Dynamic Link Warning: \(warning)")
                }
            }
            completion(shortURL)
        }
    }

    /// 앱 실행 시 전달된 dynamicLink를 처리하여 챌린지 ID를 추출합니다.
    /// - Parameter dynamicLink: 앱으로 전달된 DynamicLink 객체
    /// - Returns: 추출된 챌린지 ID (예: "challenge123"), 없으면 nil
    func handleDynamicLink(_ dynamicLink: DynamicLink?) -> String? {
        guard let url = dynamicLink?.url else { return nil }
        // URL 구조 예: https://bemechallenge.com/challenge/{challengeId}
        let pathComponents = url.pathComponents
        if pathComponents.count >= 3, pathComponents[1] == "challenge" {
            return pathComponents[2]
        }
        return nil
    }
}
