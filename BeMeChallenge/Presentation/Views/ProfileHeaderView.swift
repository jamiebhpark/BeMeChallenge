// Presentation/Views/ProfileHeaderView.swift
import SwiftUI

struct ProfileHeaderView: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    private var avatarURL: URL? {
        guard let base = viewModel.profileImageURL else { return nil }
        if let v = viewModel.profileImageUpdatedAt {
            let sep = base.contains("?") ? "&" : "?"
            return URL(string: "\(base)\(sep)v=\(Int(v))")
        }
        return URL(string: base)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color("PrimaryGradientStart"), Color("PrimaryGradientEnd")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(16)
            .shadow(radius: 4)
            
            // 위에 살짝 블러 머티리얼
            Rectangle()
                .fill(.ultraThinMaterial)
                .cornerRadius(16)
            

            HStack(spacing: 16) {
                // Avatar
                Group {
                    if let url = avatarURL {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:    ProgressView()
                            case .failure:  Image("defaultAvatar").resizable()
                            case .success(let img): img.resizable().scaledToFill()
                            @unknown default: EmptyView()
                            }
                        }
                        .id(url)
                    } else {
                        Image("defaultAvatar").resizable()
                    }
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))

                // Nickname
                Text(viewModel.nickname)
                    .font(.title2).bold()
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: "pencil")
                    .font(.title3)
                    .foregroundColor(.white)
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
    }
}
