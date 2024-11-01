import Foundation
import Combine
import SwiftUI

enum OrderFilterType {
    case active
    case archive
    
    var title: String {
        switch self {
        case .active: return "Active"
        case .archive: return "Archive"
        }
    }
}

struct DashboardOffer: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let backgroundColor: String
    let action: DashboardOfferAction
    let emoji: String
    
    static let sampleOffers: [DashboardOffer] = [
        DashboardOffer(
            title: "Spring Cleaning Special",
            description: "20% off on deep cleaning services",
            backgroundColor: "#4CAF50",
            action: .newOrder,
            emoji: "🌸"
        ),
        DashboardOffer(
            title: "Refer a Friend",
            description: "Get $50 off your next cleaning when you refer a friend",
            backgroundColor: "#2196F3",
            action: .referFriend,
            emoji: "🤝"
        ),
        DashboardOffer(
            title: "Weekly Cleaning Plan",
            description: "Sign up for our weekly plan and save 15%",
            backgroundColor: "#9C27B0",
            action: .subscription,
            emoji: "📅"
        )
    ]
}

enum DashboardOfferAction {
    case newOrder
    case referFriend
    case subscription
}

enum DashboardActiveView {
    case main
    case orderHistory
    case notifications
    case profile
}

struct OfferDetails {
    let title: String
    let description: String
    let fullDescription: String
    let terms: [String]
    let validUntil: Date
    let discount: String
    let code: String?
    
    static func details(for offer: DashboardOffer) -> OfferDetails {
        switch offer.action {
        case .newOrder:
            return OfferDetails(
                title: offer.title,
                description: offer.description,
                fullDescription: "Get a professional deep cleaning service with our certified cleaners. Perfect for spring cleaning or moving preparation.",
                terms: [
                    "Valid for new bookings only",
                    "Cannot be combined with other offers",
                    "Discount applies to service fee only",
                    "Maximum discount value of $100",
                    "Available in Vancouver and Victoria areas only"
                ],
                validUntil: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date(),
                discount: "20%",
                code: "SPRING20"
            )
        case .referFriend:
            return OfferDetails(
                title: offer.title,
                description: offer.description,
                fullDescription: "Share your love for QleanMe with friends and family. Both you and your referred friend will receive credits towards your next cleaning.",
                terms: [
                    "Referral must be a new customer",
                    "Credit applied after referred friend's first booking",
                    "Maximum of 10 referrals per year",
                    "Credits expire after 6 months",
                    "Cannot be redeemed for cash"
                ],
                validUntil: Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date(),
                discount: "$50",
                code: nil
            )
        case .subscription:
            return OfferDetails(
                title: offer.title,
                description: offer.description,
                fullDescription: "Subscribe to our weekly cleaning plan and never worry about scheduling again. Flexible scheduling and priority booking included.",
                terms: [
                    "Minimum 3-month commitment",
                    "15% discount applies to all scheduled cleanings",
                    "Free rescheduling up to 24 hours before appointment",
                    "Priority booking and preferred cleaner selection",
                    "Cancel anytime after minimum period"
                ],
                validUntil: Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date(),
                discount: "15%",
                code: "WEEKLY15"
            )
        }
    }
}

@MainActor
class RegisteredUserDashboardViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var userName: String = ""
    @Published var offers: [DashboardOffer] = []
    @Published var currentOfferIndex: Int = 0
    @Published var selectedTab: Int = 0
    @Published var activeView: DashboardActiveView = .main
    @Published var showOrderCreation = false
    @Published var selectedOrderFilter: OrderFilterType = .active
    @Published var activeOrders: [OrderWithWorkerInfo] = []
    @Published var archivedOrders: [OrderWithWorkerInfo] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showReferralProgram = false
    @Published var showSubscriptionDetails = false
    @Published var selectedOffer: DashboardOffer?
    @Published var showOfferDetails = false
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let networkManager: NetworkManager
    private var userId: Int?
    private var offerTimer: AnyCancellable?
    
    // MARK: - Computed Properties
    var filteredOrders: [OrderWithWorkerInfo] {
        switch selectedOrderFilter {
        case .active:
            return activeOrders
        case .archive:
            return archivedOrders
        }
    }
    
    var hasOrders: Bool {
        switch selectedOrderFilter {
        case .active:
            return !activeOrders.isEmpty
        case .archive:
            return !archivedOrders.isEmpty
        }
    }
    
    var showEmptyStateButton: Bool {
        selectedOrderFilter == .active
    }
    
    var emptyStateEmoji: String {
        switch selectedOrderFilter {
        case .active:
            return "🏃"
        case .archive:
            return "📝"
        }
    }
    
    var emptyStateTitle: String {
        switch selectedOrderFilter {
        case .active:
            return "No active orders"
        case .archive:
            return "No past orders"
        }
    }
    
    var emptyStateMessage: String {
        switch selectedOrderFilter {
        case .active:
            return "Ready to schedule your first cleaning?"
        case .archive:
            return "Your cleaning history will appear here"
        }
    }
    
    var emptyStateButtonTitle: String {
        switch selectedOrderFilter {
        case .active:
            return "Book Now"
        case .archive:
            return ""
        }
    }
    
    // MARK: - Initialization
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
        setupInitialData()
        setupOfferCarousel()
        Task {
            await fetchUserProfile()
            await fetchOrders()
        }
    }
    
    deinit {
        offerTimer?.cancel()
    }
    
    // MARK: - Private Methods
    private func setupInitialData() {
        offers = DashboardOffer.sampleOffers
    }
    
    private func setupOfferCarousel() {
        offerTimer = Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.currentOfferIndex = (self.currentOfferIndex + 1) % self.offers.count
            }
    }
    
    // MARK: - Public Methods
    func fetchUserProfile() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            guard let phoneNumber = UserDefaults.standard.string(forKey: "userPhoneNumber") else {
                throw NetworkError.invalidData("No phone number found. Please log in again.")
            }
            
            let profile = try await networkManager.fetchUserProfile(phoneNumber: phoneNumber)
            userId = profile.id
            userName = profile.fullName
        } catch {
            errorMessage = "Failed to load profile: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func fetchOrders() async {
        guard !isLoading else { return }
        guard let userId = userId else {
            errorMessage = "Unable to identify user. Please log in again."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let orders = try await networkManager.fetchOrders(for: userId)
            
            var activeOrdersList: [OrderWithWorkerInfo] = []
            var archivedOrdersList: [OrderWithWorkerInfo] = []
            
            for order in orders {
                do {
                    let worker = try await networkManager.fetchWorker(with: order.cleanerId)
                    let addons = try await networkManager.fetchOrderAddons(for: order.id)
                    let orderWithInfo = OrderWithWorkerInfo(
                        order: order,
                        worker: worker,
                        addons: addons
                    )
                    
                    if order.isCompleted {
                        archivedOrdersList.append(orderWithInfo)
                    } else {
                        activeOrdersList.append(orderWithInfo)
                    }
                } catch {
                    print("Error fetching details for order \(order.id): \(error)")
                    continue
                }
            }
            
            // Sort orders by date, most recent first
            activeOrdersList.sort { $0.order.dateTime > $1.order.dateTime }
            archivedOrdersList.sort { $0.order.dateTime > $1.order.dateTime }
            
            activeOrders = activeOrdersList
            archivedOrders = archivedOrdersList
            
        } catch {
            errorMessage = "Failed to load orders: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func handleOfferAction(_ action: DashboardOfferAction) {
        switch action {
        case .newOrder:
            showOrderCreation = true
        case .referFriend:
            showReferralProgram = true
        case .subscription:
            showSubscriptionDetails = true
        }
    }
    
    func selectOffer(_ offer: DashboardOffer) {
        selectedOffer = offer
        showOfferDetails = true
    }
    
    func cancelOrder(_ orderId: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await networkManager.cancelOrder(orderId: orderId)
            await fetchOrders()
        } catch {
            errorMessage = "Failed to cancel order: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Navigation Methods
    func showMainDashboard() {
        activeView = .main
        selectedTab = 0
    }
    
    func showOrderHistory() {
        activeView = .orderHistory
        selectedTab = 1
    }
    
    func showNotifications() {
        activeView = .notifications
        selectedTab = 2
    }
    
    func showProfile() {
        activeView = .profile
        selectedTab = 3
    }
}
