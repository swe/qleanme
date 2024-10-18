import SwiftUI

struct NotificationListView: View {
    @StateObject private var viewModel = NotificationListViewModel()
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage) {
                        viewModel.fetchNotifications()
                    }
                } else if viewModel.notifications.isEmpty {
                    EmptyNotificationsView()
                } else {
                    notificationList
                }
            }
            .navigationTitle("Notifications")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: markAllAsRead) {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.blue)
                            .font(.system(size: 20))
                    }
                    .disabled(viewModel.notifications.allSatisfy { $0.isRead })
                    .opacity(viewModel.notifications.allSatisfy { $0.isRead } ? 0.5 : 1.0)
                }
            }
        }
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? Color(UIColor.systemBackground) : Color.gray.opacity(0.1)
    }

    private var notificationList: some View {
        List {
            ForEach(viewModel.notifications) { notification in
                NotificationRow(notification: notification, onTap: {
                    viewModel.markAsRead(notification)
                    viewModel.handleNotificationAction(notification)
                })
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        viewModel.deleteNotification(notification)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    private func markAllAsRead() {
        for notification in viewModel.notifications {
            viewModel.markAsRead(notification)
        }
    }
}

struct NotificationRow: View {
    let notification: Notification
    let onTap: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            notificationIcon
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.headline)
                    .foregroundColor(notification.isRead ? .secondary : .primary)
                
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(notification.date, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if !notification.isRead {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
    
    private var notificationIcon: some View {
        ZStack {
            Circle()
                .fill(iconBackgroundColor)
                .frame(width: 40, height: 40)
            
            Image(systemName: iconName)
                .foregroundColor(.white)
        }
    }
    
    private var iconBackgroundColor: Color {
        switch notification.type {
        case .orderStatus:
            return .blue
        case .cardExpiring:
            return .orange
        case .orderCompleted:
            return .green
        case .ratingReminder:
            return .yellow
        case .newPromotion:
            return .purple
        case .cleanerArrived:
            return .green
        case .cleanerDelayed:
            return .orange
        case .subscriptionRenewal:
            return .blue
        case .referralBonus:
            return .purple
        case .scheduleMaintenance:
            return .indigo
        case .other:
            return .gray
        }
    }
    
    private var iconName: String {
        switch notification.type {
        case .orderStatus:
            return "clock"
        case .cardExpiring:
            return "creditcard"
        case .orderCompleted:
            return "checkmark.circle"
        case .ratingReminder:
            return "star"
        case .newPromotion:
            return "tag"
        case .cleanerArrived:
            return "person.fill.checkmark"
        case .cleanerDelayed:
            return "person.fill.xmark"
        case .subscriptionRenewal:
            return "repeat"
        case .referralBonus:
            return "gift"
        case .scheduleMaintenance:
            return "calendar.badge.exclamationmark"
        case .other:
            return "bell"
        }
    }
}

struct EmptyNotificationsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Read All")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Notifications")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("You're all caught up!")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct NotificationListView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationListView()
        
        NotificationListView()
            .preferredColorScheme(.dark)
        
        EmptyNotificationsView()
            .previewDisplayName("Empty State")
    }
}
