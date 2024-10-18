import Foundation
import Combine

struct Notification: Identifiable {
    let id = UUID()
    let type: NotificationType
    let title: String
    let message: String
    let date: Date
    var isRead: Bool
    let actionType: NotificationActionType?
    let actionData: String?
}

enum NotificationType {
    case orderStatus
    case cardExpiring
    case orderCompleted
    case ratingReminder
    case newPromotion
    case cleanerArrived
    case cleanerDelayed
    case subscriptionRenewal
    case referralBonus
    case scheduleMaintenance
    case other
}

enum NotificationActionType {
    case viewOrder
    case updateCard
    case rateOrder
    case viewPromotion
    case trackCleaner
    case renewSubscription
    case viewReferralProgram
    case scheduleService
}

class NotificationListViewModel: ObservableObject {
    @Published var notifications: [Notification] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    init() {
        fetchNotifications()
    }

    func fetchNotifications() {
        isLoading = true
        errorMessage = nil

        // Simulating API call with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Mock data including new custom notifications
            self.notifications = [
                Notification(type: .orderStatus, title: "Order Status Update", message: "Your cleaning service is scheduled for tomorrow at 2 PM.", date: Date().addingTimeInterval(-3600), isRead: false, actionType: .viewOrder, actionData: "ORDER_ID_1"),
                Notification(type: .cardExpiring, title: "Card Expiring Soon", message: "Your payment card ending in 1234 will expire next month.", date: Date().addingTimeInterval(-7200), isRead: true, actionType: .updateCard, actionData: nil),
                Notification(type: .orderCompleted, title: "Order Completed", message: "Your recent cleaning service has been completed. We hope you're satisfied!", date: Date().addingTimeInterval(-86400), isRead: false, actionType: .rateOrder, actionData: "ORDER_ID_2"),
                Notification(type: .ratingReminder, title: "Rate Your Cleaner", message: "Don't forget to rate your last cleaning experience!", date: Date().addingTimeInterval(-172800), isRead: false, actionType: .rateOrder, actionData: "ORDER_ID_3"),
                Notification(type: .newPromotion, title: "New Promotion Available", message: "Get 20% off your next cleaning service!", date: Date().addingTimeInterval(-259200), isRead: false, actionType: .viewPromotion, actionData: "PROMO_ID_1"),
                Notification(type: .cleanerArrived, title: "Cleaner Has Arrived", message: "Your cleaner has arrived at your location.", date: Date().addingTimeInterval(-300), isRead: false, actionType: .trackCleaner, actionData: "ORDER_ID_4"),
                Notification(type: .cleanerDelayed, title: "Cleaner Slightly Delayed", message: "Your cleaner is running 15 minutes late due to traffic.", date: Date().addingTimeInterval(-1800), isRead: false, actionType: .trackCleaner, actionData: "ORDER_ID_5"),
                Notification(type: .subscriptionRenewal, title: "Subscription Renewing Soon", message: "Your monthly cleaning subscription will renew in 3 days.", date: Date().addingTimeInterval(-432000), isRead: false, actionType: .renewSubscription, actionData: nil),
                Notification(type: .referralBonus, title: "Referral Bonus Earned", message: "Congratulations! You've earned a $50 credit for referring a friend.", date: Date().addingTimeInterval(-518400), isRead: false, actionType: .viewReferralProgram, actionData: nil),
                Notification(type: .scheduleMaintenance, title: "Schedule Maintenance Cleaning", message: "It's been 3 months since your last deep clean. Time to schedule one?", date: Date().addingTimeInterval(-604800), isRead: false, actionType: .scheduleService, actionData: nil)
            ]
            self.isLoading = false
        }
    }

    func markAsRead(_ notification: Notification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
        }
    }

    func deleteNotification(_ notification: Notification) {
        notifications.removeAll { $0.id == notification.id }
    }

    func handleNotificationAction(_ notification: Notification) {
        // Handle the action based on the notification type
        switch notification.actionType {
        case .viewOrder:
            print("View order: \(notification.actionData ?? "")")
        case .updateCard:
            print("Update card")
        case .rateOrder:
            print("Rate order: \(notification.actionData ?? "")")
        case .viewPromotion:
            print("View promotion: \(notification.actionData ?? "")")
        case .trackCleaner:
            print("Track cleaner for order: \(notification.actionData ?? "")")
        case .renewSubscription:
            print("Renew subscription")
        case .viewReferralProgram:
            print("View referral program")
        case .scheduleService:
            print("Schedule maintenance service")
        case .none:
            break
        }
    }
}
