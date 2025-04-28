//  SettingsRow.swift
import SwiftUI

/// 재사용 가능한 설정 행 컴포넌트 (Destination 뷰를 클로저로 주입)
struct SettingsRow<Destination: View>: View {
    let title: String
    let destination: () -> Destination

    var body: some View {
        NavigationLink(destination: destination()) {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
    }
}

