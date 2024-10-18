import Foundation
import Combine

enum CleaningAreaSize: String, CaseIterable, Identifiable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .small: return "< 500 sqft"
        case .medium: return "501-1000 sqft"
        case .large: return "> 1001 sqft"
        }
    }
    
    var icon: String {
        switch self {
        case .small: return "house"
        case .medium: return "house.lodge"
        case .large: return "building.2"
        }
    }
}

enum AdditionalCleaningService: String, CaseIterable, Identifiable {
    case fridgeCleaning = "Fridge cleaning"
    case ovenCleaning = "Oven cleaning"
    case windowsWashing = "Windows washing"
    case carpetCleaning = "Carpet cleaning"
    case petCleaning = "I have pets"
    case dishwashing = "Dishwashing"
    case bringVacuum = "Bring your vacuum"
    case insideMicrowave = "Inside microwave"
    case closetCleaning = "Closet cleaning"
    case bathCleaning = "Bath cleaning"
    case toiletCleaning = "Toilet cleaning"
    case keysPickupDelivery = "Keys pickup / delivery"
    
    var id: String { self.rawValue }
    
    var icon: (regular: String, filled: String) {
        switch self {
        case .fridgeCleaning: return ("refrigerator", "refrigerator.fill")
        case .ovenCleaning: return ("oven", "oven.fill")
        case .windowsWashing: return ("window.ceiling", "window.ceiling")
        case .carpetCleaning: return ("square.grid.2x2", "square.grid.2x2.fill")
        case .petCleaning: return ("pawprint", "pawprint.fill")
        case .dishwashing: return ("dishwasher", "dishwasher.fill")
        case .bringVacuum: return ("robotic.vacuum", "robotic.vacuum.fill")
        case .insideMicrowave: return ("microwave", "microwave.fill")
        case .closetCleaning: return ("tshirt", "tshirt.fill")
        case .bathCleaning: return ("bathtub", "bathtub.fill")
        case .toiletCleaning: return ("toilet", "toilet.fill")
        case .keysPickupDelivery: return ("key", "key.fill")
        }
    }
    
    var price: Double {
        switch self {
        case .fridgeCleaning: return 15.0
        case .ovenCleaning: return 20.0
        case .windowsWashing: return 25.0
        case .carpetCleaning: return 30.0
        case .petCleaning: return 15.0
        case .dishwashing: return 10.0
        case .bringVacuum: return 5.0
        case .insideMicrowave: return 5.0
        case .closetCleaning: return 15.0
        case .bathCleaning: return 20.0
        case .toiletCleaning: return 10.0
        case .keysPickupDelivery: return 10.0
        }
    }
}

enum RecurringServiceOption: String, CaseIterable, Identifiable {
    case none = "One-time service"
    case everyWeek = "Every week"
    case everySecondWeek = "Every second week"
    case everyMonth = "Every month"
    
    var id: String { self.rawValue }
    
    var discountPercentage: Double {
        switch self {
        case .none: return 0
        case .everyWeek: return 0.15
        case .everySecondWeek: return 0.10
        case .everyMonth: return 0.05
        }
    }
}

class OrderBaseCleaningViewModel: ObservableObject {
    @Published var numberOfBedrooms: Int = 2
    @Published var numberOfBathrooms: Int = 2
    @Published var selectedAreaSize: CleaningAreaSize = .small
    @Published var selectedAdditionalServices: Set<AdditionalCleaningService> = []
    @Published var bringCleaningProducts: Bool = true
    @Published var specialInstructions: String = ""
    @Published var selectedRecurringOption: RecurringServiceOption = .none
    
    @Published var basePrice: Double = 55.0
    @Published var totalPrice: Double = 55.0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        let publishers: [AnyPublisher<Void, Never>] = [
            $numberOfBedrooms.map { _ in () }.eraseToAnyPublisher(),
            $numberOfBathrooms.map { _ in () }.eraseToAnyPublisher(),
            $selectedAreaSize.map { _ in () }.eraseToAnyPublisher(),
            $selectedAdditionalServices.map { _ in () }.eraseToAnyPublisher(),
            $bringCleaningProducts.map { _ in () }.eraseToAnyPublisher(),
            $selectedRecurringOption.map { _ in () }.eraseToAnyPublisher()
        ]
        
        Publishers.MergeMany(publishers)
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.calculateTotalPrice()
            }
            .store(in: &cancellables)
    }
    
    func incrementBedrooms() {
        numberOfBedrooms += 1
    }
    
    func decrementBedrooms() {
        if numberOfBedrooms > 0 {
            numberOfBedrooms -= 1
        }
    }
    
    func incrementBathrooms() {
        numberOfBathrooms += 1
    }
    
    func decrementBathrooms() {
        if numberOfBathrooms > 0 {
            numberOfBathrooms -= 1
        }
    }
    
    func toggleAdditionalService(_ service: AdditionalCleaningService) {
        if selectedAdditionalServices.contains(service) {
            selectedAdditionalServices.remove(service)
        } else {
            selectedAdditionalServices.insert(service)
        }
    }
    
    func toggleBringCleaningProducts() {
        bringCleaningProducts.toggle()
    }
    
    private func calculateTotalPrice() {
        var price = basePrice
        
        // Add price for bedrooms and bathrooms
        price += Double(numberOfBedrooms + numberOfBathrooms) * 10
        
        // Add price for area size
        switch selectedAreaSize {
        case .small: price += 0
        case .medium: price += 20
        case .large: price += 40
        }
        
        // Add price for additional services
        price += selectedAdditionalServices.reduce(0) { $0 + $1.price }
        
        // Add price for bringing cleaning products
        if bringCleaningProducts {
            price += 10 // Assuming a $10 charge for bringing cleaning products
        }
        
        // Apply discount for recurring service
        let discount = price * selectedRecurringOption.discountPercentage
        price -= discount
        
        totalPrice = price
    }
    
    func printOrderDetails() {
        print("Base Cleaning Order Details:")
        print("----------------------------")
        print("Number of Bedrooms: \(numberOfBedrooms)")
        print("Number of Bathrooms: \(numberOfBathrooms)")
        print("Area Size: \(selectedAreaSize.rawValue) (\(selectedAreaSize.description))")
        print("Additional Services: \(selectedAdditionalServices.map { $0.rawValue }.joined(separator: ", "))")
        print("Bring Cleaning Products: \(bringCleaningProducts ? "Yes" : "No")")
        print("Special Instructions: \(specialInstructions)")
        print("Recurring Service: \(selectedRecurringOption.rawValue)")
        print("Total Price: $\(String(format: "%.2f", totalPrice))")
    }
}
