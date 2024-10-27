import Foundation
import Combine

@MainActor
class OrdersActiveViewModel: ObservableObject {
    @Published var orders: [OrderWithWorkerInfo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var userId: Int?
    private let networkManager: NetworkManager
    private var cancellables = Set<AnyCancellable>()
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }
    
    func toggleExpansion(for orderId: UUID) {
        if let index = orders.firstIndex(where: { $0.id == orderId }) {
            orders[index].isExpanded.toggle()
        }
    }
    
    func fetchOrders() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // First, get the user's ID using their stored phone number
            if userId == nil {
                guard let phoneNumber = UserDefaults.standard.string(forKey: "userPhoneNumber") else {
                    throw NetworkError.invalidData("No phone number found. Please log in again.")
                }
                
                let userProfile = try await networkManager.fetchUserProfile(phoneNumber: phoneNumber)
                // Store the user ID for future use
                self.userId = userProfile.id
            }
            
            guard let userId = userId else {
                throw NetworkError.invalidData("Unable to retrieve user ID")
            }
            
            // Fetch orders for the user
            let fetchedOrders = try await networkManager.fetchOrders(for: userId)
            var updatedOrders: [OrderWithWorkerInfo] = []
            
            // For each order, fetch the worker info and any addons
            for order in fetchedOrders {
                async let worker = networkManager.fetchWorker(with: order.cleanerId)
                async let addons = networkManager.fetchOrderAddons(for: order.id)
                
                let (fetchedWorker, fetchedAddons) = try await (worker, addons)
                let orderWithWorkerInfo = OrderWithWorkerInfo(
                    order: order,
                    worker: fetchedWorker,
                    addons: fetchedAddons
                )
                updatedOrders.append(orderWithWorkerInfo)
            }
            
            // Sort orders by date, most recent first
            orders = updatedOrders.sorted { $0.order.dateTime > $1.order.dateTime }
            
        } catch {
            errorMessage = handleError(error)
        }
        
        isLoading = false
    }
    
    func cancelOrder(orderId: UUID) async {
        do {
            try await networkManager.cancelOrder(orderId: orderId)
            // Remove the cancelled order from the local array
            orders.removeAll { $0.id == orderId }
        } catch {
            errorMessage = handleError(error)
        }
    }
    
    private func handleError(_ error: Error) -> String {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .invalidData(let message):
                return message
            case .serverError(let message):
                return message
            default:
                return "An unexpected error occurred: \(networkError.localizedDescription)"
            }
        }
        return "An unexpected error occurred: \(error.localizedDescription)"
    }
}

// MARK: - Supporting Types
struct OrderWithWorkerInfo: Identifiable {
    let order: Order
    var worker: PublicWorker
    var addons: [OrderAddon]
    var isExpanded: Bool = false
    
    var id: UUID { order.id }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy HH:mm"
        return formatter.string(from: order.dateTime)
    }
    
    var formattedDuration: String {
        let hours = order.duration / 60
        let minutes = order.duration % 60
        return "\(hours)h \(minutes)m"
    }
    
    var formattedPrice: String {
        return String(format: "%.2f", (order.price as NSDecimalNumber).doubleValue)
    }
    
    var cleaningSupplies: [String] {
        return addons.map { $0.addon }
    }
}
