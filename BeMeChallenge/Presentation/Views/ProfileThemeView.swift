// ProfileThemeView.swift
import SwiftUI

struct ProfileThemeView: View {
    @StateObject var viewModel = ProfileThemeViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("프로필 테마 선택")
                    .font(.headline)
                    .padding()
                
                List(viewModel.themes, id: \.id) { theme in
                    HStack {
                        Circle()
                            .fill(theme.previewColor)
                            .frame(width: 40, height: 40)
                        VStack(alignment: .leading) {
                            Text(theme.name)
                                .font(.headline)
                            Text(theme.description)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        if viewModel.selectedTheme?.id == theme.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.selectTheme(theme)
                    }
                }
                
                Button(action: {
                    viewModel.saveSelectedTheme { success in
                        if success {
                            // 성공 알림 또는 화면 종료 처리
                            print("테마 업데이트 성공!")
                        }
                    }
                }) {
                    Text("테마 업데이트")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("프로필 테마")
        }
    }
}

struct ProfileThemeView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileThemeView()
    }
}
