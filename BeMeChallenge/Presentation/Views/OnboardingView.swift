//OnboardingView.swift
import SwiftUI

// 온보딩 페이지 데이터를 표현하는 모델
struct OnboardingPage: Identifiable {
    var id = UUID()
    var imageName: String
    var title: String
    var description: String
}

struct OnboardingView: View {
    @State private var currentPage = 0
    // 온보딩 페이지 목록 (이미지 이름은 Assets에 추가되어 있어야 합니다)
    private let pages: [OnboardingPage] = [
        OnboardingPage(imageName: "onboarding1", title: "진정성 있는 순간", description: "광고 없는 순수한 일상을 공유합니다."),
        OnboardingPage(imageName: "onboarding2", title: "즉석 촬영", description: "필터 없이, 있는 그대로의 당신을 기록하세요."),
        OnboardingPage(imageName: "onboarding3", title: "특별한 챌린지", description: "참여해야만 볼 수 있는 특별한 챌린지에 도전하세요.")
    ]
    
    // 온보딩 완료 플래그 (UserDefaults를 사용하여 저장)
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        // 온보딩 완료 후, 실제 앱 메인 화면으로 전환하는 로직 (예: Coordinator 또는 EnvironmentObject 활용)
    }
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    VStack(spacing: 20) {
                        Image(pages[index].imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                        
                        Text(pages[index].title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(pages[index].description)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .animation(.easeInOut, value: currentPage)
            
            Button(action: {
                if currentPage == pages.count - 1 {
                    completeOnboarding()
                } else {
                    withAnimation {
                        currentPage += 1
                    }
                }
            }) {
                Text(currentPage == pages.count - 1 ? "시작하기" : "다음")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .onAppear {
            // 온보딩 플래그 확인 후, 이미 완료한 경우 온보딩 화면을 건너뛰는 로직 구현 가능
            if UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
                // 이미 온보딩을 완료했다면, 메인 화면으로 전환하는 처리 필요
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
