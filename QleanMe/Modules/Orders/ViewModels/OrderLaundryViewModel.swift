import Foundation
import Combine

enum LaundryServiceType: String, CaseIterable, Identifiable {
    case washing = "Washing"
    case dryCleaning = "Dry Clean"
    case ironing = "Ironing"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .washing: return "washer.fill"
        case .dryCleaning: return "bubbles.and.sparkles"
        case .ironing: return "light.max"
        }
    }
    
    var basePrice: Decimal {
        switch self {
        case .washing: return Decimal(string: "28.23")!
        case .dryCleaning: return Decimal(string: "16.93")!
        case .ironing: return Decimal(string: "14.12")!
        }
    }
    
    var description: String {
        switch self {
        case .washing: return "Standard washing service"
        case .dryCleaning: return "Professional dry cleaning"
        case .ironing: return "Professional pressing"
        }
    }
}

enum LaundryLoadSize: String, CaseIterable, Identifiable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .small: return "< 4 lb"
        case .medium: return "4-8 lb"
        case .large: return "> 8 lb"
        }
    }
    
    var priceMultiplier: Decimal {
        switch self {
        case .small: return 1.0
        case .medium:
            switch LaundryServiceType.allCases[0] {
            case .washing, .dryCleaning: return Decimal(string: "1.57")!
            case .ironing: return Decimal(string: "1.64")!
            }
        case .large:
            switch LaundryServiceType.allCases[0] {
            case .washing, .dryCleaning: return Decimal(string: "2.14")!
            case .ironing: return Decimal(string: "2.15")!
            }
        }
    }
}

enum LaundryAddonType: String, CaseIterable, Identifiable {
    case stainRemoval = "Stain Removal"
    case delicatesCare = "Delicates Care"
    case ecoFriendly = "Eco-Friendly Detergent"
    case fabricSoftener = "Fabric Softener"
    case extraRinse = "Extra Rinse"
    
    var id: String { rawValue }
    
    var name: String { rawValue }
    
    var iconName: String {
        switch self {
        case .stainRemoval: return "sparkles"
        case .delicatesCare: return "hand.raised.fill"
        case .ecoFriendly: return "leaf.fill"
        case .fabricSoftener: return "cloud.fill"
        case .extraRinse: return "drop.fill"
        }
    }
    
    var price: Decimal {
        switch self {
        case .stainRemoval: return Decimal(string: "5.30")!
        case .delicatesCare: return Decimal(string: "7.20")!
        case .ecoFriendly: return Decimal(string: "3.10")!
        case .fabricSoftener: return Decimal(string: "2.40")!
        case .extraRinse: return Decimal(string: "4.60")!
        }
    }
}

struct LaundryAddress: Identifiable, Equatable {
    let id: String
    let title: String
    let fullAddress: String
    let type: AddressType
    let isDefault: Bool
    
    enum AddressType {
        case home
        case work
        case other
        
        var iconName: String {
            switch self {
            case .home: return "house.fill"
            case .work: return "briefcase.fill"
            case .other: return "mappin.circle.fill"
            }
        }
    }
}

@MainActor
class OrderLaundryViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedService: LaundryServiceType = .washing
    @Published var selectedLoadSize: LaundryLoadSize = .small
    @Published var selectedAddons: Set<LaundryAddonType> = []
    @Published var clothesAmount: Int = 1
    @Published var selectedDate = Date()
    @Published var selectedTime = Date()
    @Published var specialInstructions: String = ""
    @Published var showDatePicker = false
    @Published var showTimePicker = false
    @Published var showLocationPicker = false
    @Published var navigateToLocation = false
    @Published var selectedAddress: LaundryAddress?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var savedAddresses: [LaundryAddress] = []
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let networkManager: NetworkManager
    
    // MARK: - Computed Properties
    var minimumDate: Date {
        let daysToAdd = selectedService == .dryCleaning ? 3 : 1
        return Calendar.current.date(byAdding: .day, value: daysToAdd, to: Date()) ?? Date()
    }
    
    var maximumDate: Date {
        Calendar.current.date(byAdding: .month, value: 2, to: minimumDate) ?? Date()
    }
    
    var basePrice: Decimal {
        if selectedService == .dryCleaning {
            return selectedService.basePrice * Decimal(clothesAmount)
        } else {
            return selectedService.basePrice * selectedLoadSize.priceMultiplier
        }
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
        return hour >= 8 && hour < 20 && selectedAddress != nil
    }
    
    // MARK: - Initialization
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
        setupInitialData()
    }
    
    // MARK: - Private Methods
    private func setupInitialData() {
        // Set initial time to next available hour
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: Date())
        components.hour = max(min(components.hour ?? 8, 19), 8)
        components.minute = 0
        selectedTime = calendar.date(from: components) ?? Date()
        
        // Load saved addresses
        Task {
            await loadSavedAddresses()
        }
    }
    
    // MARK: - Public Methods
    func selectService(_ service: LaundryServiceType) {
        selectedService = service
        if service == .dryCleaning {
            selectedDate = minimumDate
        }
        if service != .washing {
            selectedAddons.removeAll()
        }
    }
    
    func selectLoadSize(_ size: LaundryLoadSize) {
        selectedLoadSize = size
    }
    
    func toggleAddon(_ addon: LaundryAddonType) {
        if selectedAddons.contains(addon) {
            selectedAddons.remove(addon)
        } else {
            selectedAddons.insert(addon)
        }
    }
    
    func incrementClothes() {
        clothesAmount += 1
    }
    
    func decrementClothes() {
        if clothesAmount > 1 {
            clothesAmount -= 1
        }
    }
    
    func setAddress(_ address: LaundryAddress) {
        selectedAddress = address
        showLocationPicker = false
    }
    
    func loadSavedAddresses() async {
        isLoading = true
        do {
            // Simulated network delay
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Mock data for demonstration
            savedAddresses = [
                LaundryAddress(id: "1", title: "Home", fullAddress: "123 Main St, Vancouver, BC V6B 2W9", type: .home, isDefault: true),
                LaundryAddress(id: "2", title: "Work", fullAddress: "456 Office Ave, Vancouver, BC V6C 1X6", type: .work, isDefault: false),
                LaundryAddress(id: "3", title: "Gym", fullAddress: "789 Fitness Blvd, Vancouver, BC V6E 1V3", type: .other, isDefault: false)
            ]
            
            // Set default address if none selected
            if selectedAddress == nil {
                selectedAddress = savedAddresses.first { $0.isDefault }
            }
            
        } catch {
            errorMessage = "Failed to load addresses: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func validateOrder() -> Bool {
        guard selectedAddress != nil else {
            errorMessage = "Please select a pickup address"
            return false
        }
        
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
        
        let order = createOrderSummary()
        print("Order Summary:")
        print(order)
        
        navigateToLocation = true
    }
    
    // MARK: - Helper Methods
    private func createOrderSummary() -> [String: Any] {
        [
            "service": selectedService.rawValue,
            "loadSize": selectedLoadSize.rawValue,
            "clothesAmount": clothesAmount,
            "addons": selectedAddons.map { $0.rawValue },
            "date": selectedDate,
            "time": selectedTime,
            "address": [
                "id": selectedAddress?.id ?? "",
                "fullAddress": selectedAddress?.fullAddress ?? ""
            ],
            "specialInstructions": specialInstructions,
            "totalPrice": NSDecimalNumber(decimal: totalPrice).doubleValue
        ]
    }
}
