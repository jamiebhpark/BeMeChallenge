//SectionHeaderView.swift
import SwiftUI

/// A single, shared section header
struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .font(.title3).bold()
                .padding(.vertical, 8)
            Spacer()
        }
        .padding(.horizontal)
    }
}
