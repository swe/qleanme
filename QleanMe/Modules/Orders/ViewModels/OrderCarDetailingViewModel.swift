import Foundation
import Combine

enum CarType: String, CaseIterable, Identifiable {
    case car = "Car"
    case suv = "SUV"
    case truck = "Truck"
    case lorry = "Lorry"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .car: return "car.fill"
        case .suv: return "car.fill"  // Using car.fill as SwiftUI doesn't have SUV icon
        case .truck: return "truck.pickup.fill"
        case .lorry: return "truck.box.fill"
        }
    }
    
    var description: String {
        switch self {
        case .car: return "Standard size passenger vehicle"
        case .suv: return "Sport utility vehicle or minivan"
        case .truck: return "Pickup truck or similar"
        case .lorry: return "Commercial truck or large vehicle"
        }
    }
}

enum CleaningType: String, CaseIterable, Identifiable {
    case exterior = "Exterior"
    case interior = "Interior"
    case both = "Full Service"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .exterior: return "spray.fill"
        case .interior: return "car.interior"
        case .both: return "sparkles.fill"
        }
    }
    
    var description: String {
        switch self {
        case .exterior: return "Professional exterior cleaning"
        case .interior: return "Thorough interior detailing"
        case .both: return "Complete interior & exterior service"
        }
    }
}

enum CleaningDepth: String, CaseIterable, Identifiable {
    case light = "Light"
    case medium = "Medium"
    case full = "Full"
    
    var id: String { rawValue }
    
    var price: Decimal {
        switch self {
        case .light: return Decimal(string: "242.36")!
        case .medium: return Decimal(string: "361.42")!
        case .full: return Decimal(string: "483.17")!
        }
    }
    
    var description: String {
        switch self {
        case .light: return "Basic cleaning and detailing"
        case .medium: return "Enhanced cleaning with extra care"
        case .full: return "Premium detailing with special treatment"
        }
    }
    
    var features: [String] {
        switch self {
        case .light:
            return [
                "Exterior wash and dry",
                "Basic interior vacuum",
                "Windows cleaning",
                "Tire dressing"
            ]
        case .medium:
            return [
                "All Light features",
                "Clay bar treatment",
                "Carpet shampooing",
                "Leather conditioning",
                "Paint sealant"
            ]
        case .full:
            return [
                "All Medium features",
                "Paint correction",
                "Ceramic coating",
                "Headlight restoration",
                "Premium wax",
                "Complete sanitization"
            ]
        }
    }
}

struct CarDetailingAddon: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let price: Decimal
    let iconName: String
    
    static let petHairRemoval = CarDetailingAddon(
        name: "Pet Hair Removal",
        price: Decimal(string: "108.23")!,
        iconName: "pawprint.fill"
    )
    
    static let engineBayCleaning = CarDetailingAddon(
        name: "Engine Bay Cleaning",
        price: Decimal(string: "67.11")!,
        iconName: "wrench.fill"
    )
    
    static let algaeRemoval = CarDetailingAddon(
        name: "Algae Removal",
        price: Decimal(string: "138.84")!,
        iconName: "leaf.fill"
    )
    
    static let allAddons: [CarDetailingAddon] = [
        petHairRemoval,
        engineBayCleaning,
        algaeRemoval
    ]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CarDetailingAddon, rhs: CarDetailingAddon) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
class OrderCarDetailingViewModel: ObservableObject {
    @Published var selectedCarType: CarType = .car
    @Published var selectedCleaningType: CleaningType = .both
    @Published var selectedDepth: CleaningDepth = .medium
    @Published var selectedAddons: Set<CarDetailingAddon> = []
    @Published var specialInstructions: String = ""
    @Published var showDatePicker = false
    @Published var showTimePicker = false
    @Published var selectedDate = Date()
    @Published var selectedTime = Date()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var navigateToLocation = false
    @Published var isSubmitting = false
    
    private let networkManager: NetworkManager
    private let userDefaults = UserDefaults.standard
    private var userId: Int?
    
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
        setupInitialDateTime()
        loadUserId()
    }
    
    private func loadUserId() {
        Task {
            do {
                if let phoneNumber = userDefaults.string(forKey: "userPhoneNumber") {
                    let userProfile = try await networkManager.fetchUserProfile(phoneNumber: phoneNumber)
                    await MainActor.run {
                        self.userId = userProfile.id
                    }
                }
            } catch {
                print("Error loading user ID: \(error)")
            }
        }
    }
    
    var basePrice: Decimal {
        selectedDepth.price
    }
    
    var addonsPrice: Decimal {
        selectedAddons.reduce(Decimal.zero) { $0 + $1.price }
    }
    
    var totalPrice: Decimal {
        basePrice + addonsPrice
    }
    
    var canProceed: Bool {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: selectedTime)
        return hour >= 8 && hour < 20
    }
    
    private func setupInitialDateTime() {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: Date())
        components.hour = max(min(components.hour ?? 8, 19), 8)
        components.minute = 0
        selectedTime = calendar.date(from: components) ?? Date()
    }
    
    func toggleAddon(_ addon: CarDetailingAddon) {
        if selectedAddons.contains(addon) {
            selectedAddons.remove(addon)
        } else {
            selectedAddons.insert(addon)
        }
    }
    
    func validateOrder() -> Bool {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: selectedTime)
        guard hour >= 8 && hour < 20 else {
            errorMessage = "Please select a time between 8 AM and 8 PM"
            return false
        }
        
        return true
    }
    
    func proceedToLocation() {
        guard validateOrder() else { return }
        submitOrder()
    }
    
    private func submitOrder() {
        guard let userId = userId else {
            errorMessage = "Unable to identify user. Please try logging in again."
            return
        }
        
        isSubmitting = true
        errorMessage = nil
        
        // Combine date and time
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
        guard let dateWithTime = calendar.date(bySettingHour: timeComponents.hour ?? 0,
                                             minute: timeComponents.minute ?? 0,
                                             second: 0,
                                             of: selectedDate) else {
            errorMessage = "Invalid date/time selection"
            isSubmitting = false
            return
        }
        
        let orderId = UUID()
        
        Task {
            do {
                // Submit main order
                try await networkManager.submitOrder(
                    userId: userId,
                    vehicleType: "\(selectedCarType.rawValue) Detailing",
                    dateTime: dateWithTime,
                    price: totalPrice,
                    duration: 120, // 2 hours default
                    // address: "555 Austin Ave, Coquitlam", // This was the missing parameter
                    specialInstructions: specialInstructions.isEmpty ? nil : specialInstructions
                )
                
                // Submit addons if any
                if !selectedAddons.isEmpty {
                    try await networkManager.submitOrderAddons(
                        orderId: orderId,
                        addons: selectedAddons.map { $0.name }
                    )
                }
                
                await MainActor.run {
                    isSubmitting = false
                    navigateToLocation = true
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    errorMessage = "Failed to submit order: \(error.localizedDescription)"
                }
            }
        }
    }
}
