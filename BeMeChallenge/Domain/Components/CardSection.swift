//  CardSection.swift
import SwiftUI

/// “떠 있는 카드” 스타일의 공통 섹션 컴포넌트
struct CardSection<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        VStack { content }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            .padding(.horizontal)
    }
}

