import Foundation
import Combine
import CoreLocation

struct OrderReviewItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String?
    let price: Decimal?
    let icon: String
}

@MainActor
class ReviewOrderViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isProcessingPayment = false
    @Published var showPaymentSuccess = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var locationCoordinate: CLLocationCoordinate2D?
    @Published var showStripePaymentSheet = false
    @Published var paymentIntentClientSecret: String?
    @Published var orderSubmissionSuccess = false
    
    // MARK: - Properties
    let orderItems: [OrderReviewItem]
    let orderDate: Date
    let orderTime: Date
    let address: String
    let totalAmount: Decimal
    let additionalDetails: [String: Any]
    
    private let geocoder = CLGeocoder()
    private let networkManager: NetworkManager
    private var cancellables = Set<AnyCancellable>()
    private var orderId: UUID?
    
    // MARK: - Computed Properties
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: combinedDateTime)
    }
    
    var formattedAddress: String {
        address
    }
    
    var combinedDateTime: Date {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: orderTime)
        return calendar.date(bySettingHour: timeComponents.hour ?? 0,
                           minute: timeComponents.minute ?? 0,
                           second: 0,
                           of: orderDate) ?? orderDate
    }
    
    var subtotal: Decimal {
        orderItems.compactMap { $0.price }.reduce(0, +)
    }
    
    var formattedTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: totalAmount as NSDecimalNumber) ?? "$0.00"
    }
    
    // MARK: - Initialization
    init(orderItems: [OrderReviewItem],
         orderDate: Date,
         orderTime: Date,
         address: String,
         totalAmount: Decimal,
         additionalDetails: [String: Any],
         networkManager: NetworkManager = .shared) {
        self.orderItems = orderItems
        self.orderDate = orderDate
        self.orderTime = orderTime
        self.address = address
        self.totalAmount = totalAmount
        self.additionalDetails = additionalDetails
        self.networkManager = networkManager
        
        Task {
            await geocodeAddress()
        }
    }
    
    // MARK: - Public Methods
    func processOrder() async {
        guard !isProcessingPayment else { return }
        
        isProcessingPayment = true
        errorMessage = nil
        
        do {
            // 1. Submit order to get orderId
            let orderId = try await submitOrder()
            self.orderId = orderId
            
            // 2. Create payment intent
            let clientSecret = try await createPaymentIntent()
            
            await MainActor.run {
                self.paymentIntentClientSecret = clientSecret
                self.showStripePaymentSheet = true
            }
        } catch {
            await handleError(error)
        }
    }
    
    func handlePaymentSuccess() async {
        do {
            guard let orderId = orderId else {
                throw NetworkError.invalidData("Order ID not found")
            }
            
            // Update order status to confirmed
            //try await networkManager.updateOrderStatus(orderId: orderId, status: "confirmed")
            
            await MainActor.run {
                self.isProcessingPayment = false
                self.showPaymentSuccess = true
            }
        } catch {
            await handleError(error)
        }
    }
    
    func handlePaymentFailure(_ error: Error) async {
        await handleError(error)
        
        // Cleanup if needed
        if let orderId = orderId {
            do {
                print("pipka")
                //try await networkManager.updateOrderStatus(orderId: orderId, status: "payment_failed")
            } catch {
                print("Failed to update order status: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Private Methods
    private func geocodeAddress() async {
        do {
            let placemarks = try await geocoder.geocodeAddressString(address)
            if let location = placemarks.first?.location?.coordinate {
                await MainActor.run {
                    self.locationCoordinate = location
                }
            }
        } catch {
            print("Geocoding error: \(error.localizedDescription)")
            // Fallback to Vancouver coordinates
            await MainActor.run {
                self.locationCoordinate = CLLocationCoordinate2D(latitude: 49.2827, longitude: -123.1207)
            }
        }
    }
    
    private func submitOrder() async throws -> UUID {
        // Get user ID from UserDefaults
        guard let phoneNumber = UserDefaults.standard.string(forKey: "userPhoneNumber") else {
            throw NetworkError.invalidData("User not found. Please log in again.")
        }
        
        // Fetch user profile to get ID
        let userProfile = try await networkManager.fetchUserProfile(phoneNumber: phoneNumber)
        
        // Submit the order
        return try await networkManager.submitOrder(
            userId: userProfile.id,
            vehicleType: orderItems[0].title, // Main service type
            dateTime: combinedDateTime,
            price: totalAmount,
            duration: 120, // Default 2 hours
            specialInstructions: additionalDetails["specialInstructions"] as? String
        )
    }
    
    private func createPaymentIntent() async throws -> String {
        // In a real implementation, this would call your backend to create a PaymentIntent
        // For demo purposes, we'll simulate a delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return "mock_payment_intent_secret"
    }
    
    private func handleError(_ error: Error) async {
        await MainActor.run {
            self.isProcessingPayment = false
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
    }
    
    // MARK: - Helper Methods
    func getOrderSummary() -> [String: Any] {
        var summary: [String: Any] = [
            "orderItems": orderItems.map { item in
                [
                    "title": item.title,
                    "subtitle": item.subtitle as Any,
                    "price": (item.price as NSDecimalNumber?)?.stringValue as Any
                ]
            },
            "dateTime": combinedDateTime,
            "address": address,
            "totalAmount": (totalAmount as NSDecimalNumber).stringValue
        ]
        
        // Add additional details
        for (key, value) in additionalDetails {
            summary[key] = value
        }
        
        return summary
    }
    
    func formatPrice(_ price: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: price as NSDecimalNumber) ?? "$0.00"
    }
}

// MARK: - Supporting Types
extension ReviewOrderViewModel {
    enum OrderSubmissionError: Error {
        case invalidUserData
        case paymentFailed
        case serverError
        
        var localizedDescription: String {
            switch self {
            case .invalidUserData:
                return "Unable to retrieve user information. Please try logging in again."
            case .paymentFailed:
                return "Payment processing failed. Please try again."
            case .serverError:
                return "Unable to process your order. Please try again later."
            }
        }
    }
}

// MARK: - Preview Helpers
extension ReviewOrderViewModel {
    static var preview: ReviewOrderViewModel {
        let items = [
            OrderReviewItem(
                title: "Regular Cleaning",
                subtitle: "2 bedrooms, 2 bathrooms",
                price: Decimal(string: "149.99"),
                icon: "house.fill"
            ),
            OrderReviewItem(
                title: "Extra Services",
                subtitle: "Window cleaning",
                price: Decimal(string: "49.99"),
                icon: "sparkles"
            )
        ]
        
        return ReviewOrderViewModel(
            orderItems: items,
            orderDate: Date(),
            orderTime: Date(),
            address: "123 Main St, Vancouver, BC V6B 2W9",
            totalAmount: Decimal(string: "199.98")!,
            additionalDetails: [
                "specialInstructions": "Please be careful with the plants",
                "hasPets": true,
                "petDetails": "One friendly dog"
            ]
        )
    }
}
