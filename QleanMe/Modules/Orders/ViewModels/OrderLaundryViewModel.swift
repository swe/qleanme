import SwiftUI
import Combine

enum LaundryServiceType: String, CaseIterable, Identifiable {
    case washAndFold = "Wash & Fold"
    case dryClean = "Dry Clean"
    case ironingOnly = "Ironing Only"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .washAndFold: return "washer"
        case .dryClean: return "bubbles.and.sparkles"
        case .ironingOnly: return "flame"
        }
    }
    
    var filledIcon: String {
        switch self {
        case .washAndFold: return "washer.fill"
        case .dryClean: return "bubbles.and.sparkles.fill"
        case .ironingOnly: return "flame.fill"
        }
    }
    
    func basePrice(for size: LoadSize) -> Double {
        switch self {
        case .washAndFold:
            return size.washAndFoldPrice
        case .dryClean:
            return size.dryCleanPrice
        case .ironingOnly:
            return size.ironingPrice
        }
    }
    
    var allowsAdditionalServices: Bool {
        self == .washAndFold
    }
    
    var dryCleanNote: String? {
        if self == .dryClean {
            return "Please note: Dry cleaning requires special care and attention. We strive to complete your order within three business days to ensure the best results for your garments."
        }
        return nil
    }
}

enum LoadSize: String, CaseIterable, Identifiable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    
    var id: String { self.rawValue }
    
    var name: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        }
    }
    
    var icon: String {
        switch self {
        case .small: return "basket"
        case .medium: return "duffle.bag"
        case .large: return "bag"
        }
    }
    
    var washAndFoldPrice: Double {
        switch self {
        case .small: return 49.7
        case .medium: return 59.9
        case .large: return 69.8
        }
    }
    
    var dryCleanPrice: Double {
        switch self {
        case .small: return 64.8
        case .medium: return 79.9
        case .large: return 94.7
        }
    }
    
    var ironingPrice: Double {
        switch self {
        case .small: return 37.4
        case .medium: return 47.6
        case .large: return 57.3
        }
    }
}

enum AdditionalLaundryService: String, CaseIterable, Identifiable {
    case stainRemoval = "Stain Removal"
    case delicatesCare = "Delicates Care"
    case ecofriendlyDetergent = "Eco-Friendly Detergent"
    case fabricSoftener = "Fabric Softener"
    case extraRinse = "Extra Rinse"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .stainRemoval: return "burst"
        case .delicatesCare: return "hand.raised"
        case .ecofriendlyDetergent: return "leaf"
        case .fabricSoftener: return "cloud"
        case .extraRinse: return "drop"
        }
    }
    
    var filledIcon: String {
        switch self {
        case .stainRemoval: return "burst.fill"
        case .delicatesCare: return "hand.raised.fill"
        case .ecofriendlyDetergent: return "leaf.fill"
        case .fabricSoftener: return "cloud.fill"
        case .extraRinse: return "drop.fill"
        }
    }
    
    var price: Double {
        switch self {
        case .stainRemoval: return 5.3
        case .delicatesCare: return 7.2
        case .ecofriendlyDetergent: return 3.1
        case .fabricSoftener: return 2.4
        case .extraRinse: return 4.6
        }
    }
}

class OrderLaundryViewModel: ObservableObject {
    @Published var serviceType: LaundryServiceType = .washAndFold
    @Published var loadSize: LoadSize = .medium
    @Published var additionalServices: Set<AdditionalLaundryService> = []
    @Published var specialInstructions: String = ""
    @Published var selectedDate: Date = Date().addingTimeInterval(86400) // Tomorrow
    @Published var selectedTime: Date = Date()
    
    @Published var isNextButtonActive: Bool = true
    @Published var basePrice: Double = 0
    @Published var additionalServicesPrice: Double = 0
    @Published var totalPrice: Double = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        Publishers.CombineLatest3($serviceType, $loadSize, $additionalServices)
            .sink { [weak self] _, _, _ in
                self?.updatePrices()
            }
            .store(in: &cancellables)
    }
    
    func toggleAdditionalService(_ service: AdditionalLaundryService) {
        if additionalServices.contains(service) {
            additionalServices.remove(service)
        } else {
            additionalServices.insert(service)
        }
    }
    
    private func updatePrices() {
        // Base price calculation
        basePrice = serviceType.basePrice(for: loadSize)
        
        // Additional services price calculation
        additionalServicesPrice = serviceType.allowsAdditionalServices ?
            additionalServices.reduce(0) { $0 + $1.price } : 0
        
        // Total price calculation
        totalPrice = basePrice + additionalServicesPrice
    }
    
    func printCollectedData() {
        print("Laundry Order Details:")
        print("----------------------")
        print("Service Type: \(serviceType.rawValue)")
        print("Load Size: \(loadSize.name)")
        if serviceType.allowsAdditionalServices {
            print("Additional Services: \(additionalServices.map { $0.rawValue }.joined(separator: ", "))")
        }
        print("Special Instructions: \(specialInstructions)")
        print("Selected Date: \(formattedDate(selectedDate))")
        print("Selected Time: \(formattedTime(selectedTime))")
        print("Base Price: $\(String(format: "%.2f", basePrice))")
        if serviceType.allowsAdditionalServices {
            print("Additional Services Price: $\(String(format: "%.2f", additionalServicesPrice))")
        }
        print("Total Price: $\(String(format: "%.2f", totalPrice))")
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
