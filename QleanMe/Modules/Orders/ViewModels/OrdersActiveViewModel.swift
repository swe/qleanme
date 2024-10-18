import Foundation
import SwiftUI
import Combine

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
        return "$\(order.price)"
    }

    var cleaningSupplies: [String] {
        return addons.map { $0.addon }
    }
}

@MainActor
class OrdersActiveViewModel: ObservableObject {
    @Published var orders: [OrderWithWorkerInfo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    func fetchOrders() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedOrders = try await NetworkManager.shared.fetchOrders(for: 1)
            var updatedOrders: [OrderWithWorkerInfo] = []

            for order in fetchedOrders {
                async let worker = NetworkManager.shared.fetchWorker(with: order.cleanerId)
                async let addons = NetworkManager.shared.fetchOrderAddons(for: order.id)
                
                let (fetchedWorker, fetchedAddons) = try await (worker, addons)
                let orderWithWorkerInfo = OrderWithWorkerInfo(order: order, worker: fetchedWorker, addons: fetchedAddons)
                updatedOrders.append(orderWithWorkerInfo)
            }

            orders = updatedOrders
            isLoading = false
        } catch {
            errorMessage = "Failed to fetch orders: \(error.localizedDescription)"
            isLoading = false
        }
    }

    func toggleExpansion(for orderId: UUID) {
        if let index = orders.firstIndex(where: { $0.id == orderId }) {
            orders[index].isExpanded.toggle()
        }
    }

    func cancelOrder(orderId: UUID) async {
        do {
            try await NetworkManager.shared.cancelOrder(orderId: orderId)
            // Remove the cancelled order from the local array
            orders.removeAll { $0.id == orderId }
        } catch {
            errorMessage = "Failed to cancel order: \(error.localizedDescription)"
        }
    }
}
