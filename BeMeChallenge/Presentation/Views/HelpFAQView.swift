// Presentation/Views/HelpFAQView.swift
import SwiftUI

// FAQ 항목 모델 (간단한 struct)
struct FAQItem: Identifiable {
    var id = UUID()
    var question: String
    var answer: String
}

struct HelpFAQView: View {
    // 샘플 FAQ 데이터
    let faqs: [FAQItem] = [
        FAQItem(question: "앱 사용에 문제가 발생하면 어떻게 해야 하나요?",
                answer: "문제가 발생하면 '문의하기' 버튼을 눌러 이메일로 문의해 주세요."),
        FAQItem(question: "내 정보는 안전하게 보호되나요?",
                answer: "네, 사용자의 모든 정보는 안전하게 보호되며, Firebase를 통해 관리됩니다."),
        FAQItem(question: "챌린지 참여 방법은 무엇인가요?",
                answer: "소셜 로그인 후 챌린지 목록에서 원하는 챌린지를 선택하여 참여하세요.")
        // 필요 시 추가 FAQ 항목을 여기에 추가합니다.
    ]
    
    var body: some View {
        NavigationView {
            List(faqs) { faq in
                VStack(alignment: .leading, spacing: 8) {
                    Text(faq.question)
                        .font(.headline)
                    Text(faq.answer)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("도움말 및 FAQ")
            .toolbar {
                NavigationLink(destination: ContactSupportView()) {
                    Text("문의하기")
                }
            }
        }
    }
}

struct HelpFAQView_Previews: PreviewProvider {
    static var previews: some View {
        HelpFAQView()
    }
}
