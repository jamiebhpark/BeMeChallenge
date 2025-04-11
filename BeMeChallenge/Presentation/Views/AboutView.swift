import SwiftUI

struct AboutView: View {
    // 앱 버전을 Bundle에서 읽어옵니다.
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 앱 로고: Assets에 추가된 앱 로고 파일("appLogo")을 사용합니다.
                Image("appLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.top, 40)
                
                Text("BeMe Challenge")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Version \(appVersion)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Divider()
                    .padding(.vertical, 20)
                
                // 앱 설명 및 개인정보 처리방침 안내 내용
                VStack(alignment: .leading, spacing: 16) {
                    Text("About")
                        .font(.headline)
                    
                    Text("BeMe Challenge는 진정성 있는 실시간 콘텐츠를 통해 사용자가 서로 소통할 수 있는 SNS 서비스입니다. 필터 없이 있는 그대로의 순간을 공유하며, 다양한 챌린지를 통해 친구들과 더욱 깊은 관계를 형성할 수 있습니다.")
                        .font(.body)
                    
                    Text("Privacy & Security")
                        .font(.headline)
                    
                    Text("귀하의 개인정보와 데이터는 Firebase를 기반으로 안전하게 관리됩니다. 당사는 사용자의 개인 정보를 소중하게 다루며, 이를 제3자와 공유하지 않습니다.")
                        .font(.body)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 개인정보 처리방침 링크 버튼
                Button(action: {
                    if let privacyURL = URL(string: "https://bemechallenge.com/privacy") {
                        UIApplication.shared.open(privacyURL)
                    }
                }) {
                    Text("Privacy Policy")
                        .font(.footnote)
                        .underline()
                }
                .padding(.bottom, 20)
            }
            .padding()
            .navigationTitle("About")
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
