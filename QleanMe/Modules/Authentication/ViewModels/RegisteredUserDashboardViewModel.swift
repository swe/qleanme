import Foundation
import Combine

enum DashboardActiveView {
    case main
    case orderHistory
    case notifications
    case profile
}

struct Offer: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
}

class RegisteredUserDashboardViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var offers: [Offer] = []
    @Published var currentOfferIndex: Int = 0
    @Published var selectedTab: Int = 0
    @Published var activeView: DashboardActiveView = .main
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchUserName()
        fetchOffers()
        startOfferCarousel()
    }
    
    private func fetchUserName() {
        // TODO: Implement actual user name fetching from Supabase
        userName = "John"  // Placeholder
    }
    
    private func fetchOffers() {
        // TODO: Implement actual offer fetching from Supabase
        offers = [
            Offer(title: "Spring Cleaning Special", description: "20% off on deep cleaning services", imageName: "offer"),
            Offer(title: "Refer a Friend", description: "Get $50 off your next cleaning when you refer a friend", imageName: "offer"),
            Offer(title: "Weekly Cleaning Plan", description: "Sign up for our weekly plan and save 15%", imageName: "offer")
        ]
    }
    
    private func startOfferCarousel() {
        Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.currentOfferIndex = (self.currentOfferIndex + 1) % self.offers.count
            }
            .store(in: &cancellables)
    }
    
    func orderCleaning() {
        // TODO: Implement navigation to cleaning order flow
        print("Navigate to cleaning order flow")
    }
    
    func showMainDashboard() {
        activeView = .main
        selectedTab = 0 // Index of the house icon
    }
    
    func showOrderHistory() {
        activeView = .orderHistory
        selectedTab = 1 // Index of the tray icon
    }
    
    func showNotifications() {
        activeView = .notifications
        selectedTab = 3 // Index of the bell icon
    }
    
    func showProfile() {
        activeView = .profile
        selectedTab = 4 // Index of the person icon
    }
}
