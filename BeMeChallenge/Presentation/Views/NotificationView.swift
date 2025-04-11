// Presentation/Views/NotificationsView.swift
import SwiftUI

struct NotificationsView: View {
    @StateObject var viewModel = NotificationViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.notifications) { notification in
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.headline)
                    Text(notification.message)
                        .font(.subheadline)
                    Text(notification.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("알림")
            .onAppear {
                viewModel.fetchNotifications()
            }
        }
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
