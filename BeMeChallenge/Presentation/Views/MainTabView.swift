// MainTabView.swift
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("홈")
                }
            CameraView()
                .tabItem {
                    Image(systemName: "plus.app.fill")
                    Text("촬영")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("프로필")
                }
        }
        .accentColor(Color("PrimaryGradientEnd")) // 디자인 가이드에 맞게 적용
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
