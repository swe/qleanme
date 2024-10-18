import SwiftUI
import Combine

enum CarSize: String, CaseIterable, Identifiable {
    case standard = "Standard"
    case suv = "SUV"
    case truck = "Truck"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .standard: return "car.side"
        case .suv: return "suv.side"
        case .truck: return "truck.pickup.side"
        }
    }
    
    var filledIcon: String {
        switch self {
        case .standard: return "car.side.fill"
        case .suv: return "suv.side.fill"
        case .truck: return "truck.pickup.side.fill"
        }
    }
}

enum AdditionalService: String, CaseIterable, Identifiable {
    case engineBayDetailing = "Engine Bay Detailing"
    case headlightRestoration = "Headlight Restoration"
    case clayBarTreatment = "Clay Bar Treatment"
    case leatherConditioning = "Leather Conditioning"
    case petHairRemoval = "Pet Hair Removal"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .engineBayDetailing: return "engine.combustion"
        case .headlightRestoration: return "headlight.daytime"
        case .clayBarTreatment: return "paintbrush"
        case .leatherConditioning: return "humidifier.and.droplets"
        case .petHairRemoval: return "pawprint"
        }
    }
    
    var filledIcon: String {
        switch self {
        case .engineBayDetailing: return "engine.combustion.fill"
        case .headlightRestoration: return "headlight.daytime.fill"
        case .clayBarTreatment: return "paintbrush.fill"
        case .leatherConditioning: return "humidifier.and.droplets.fill"
        case .petHairRemoval: return "pawprint.fill"
        }
    }
}

class OrderCarDetailingViewModel: ObservableObject {
    @Published var carSize: CarSize = .standard
    @Published var interiorCleaning: Bool = true
    @Published var exteriorCleaning: Bool = true
    @Published var additionalServices: Set<AdditionalService> = []
    @Published var specialInstructions: String = ""
    @Published var selectedDate: Date = Date().addingTimeInterval(86400) // Tomorrow
    @Published var selectedTime: Date = Date()
    
    @Published var isNextButtonActive: Bool = false
    @Published var basePrice: Double = 0
    @Published var additionalServicesPrice: Double = 0
    @Published var totalPrice: Double = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        Publishers.CombineLatest3($interiorCleaning, $exteriorCleaning, $carSize)
            .map { interior, exterior, _ in
                interior || exterior
            }
            .assign(to: \.isNextButtonActive, on: self)
            .store(in: &cancellables)
        
        Publishers.CombineLatest4($carSize, $interiorCleaning, $exteriorCleaning, $additionalServices)
            .sink { [weak self] size, interior, exterior, additionalServices in
                self?.updatePrices(size: size, interior: interior, exterior: exterior, additionalServices: additionalServices)
            }
            .store(in: &cancellables)
    }
    
    func toggleAdditionalService(_ service: AdditionalService) {
        if additionalServices.contains(service) {
            additionalServices.remove(service)
        } else {
            additionalServices.insert(service)
        }
    }
    
    private func updatePrices(size: CarSize, interior: Bool, exterior: Bool, additionalServices: Set<AdditionalService>) {
        // Base price calculation
        basePrice = size.basePrice
        if interior {
            basePrice += size.interiorPrice
        }
        if exterior {
            basePrice += size.exteriorPrice
        }
        
        // Additional services price calculation
        additionalServicesPrice = additionalServices.reduce(0) { $0 + $1.price }
        
        // Total price calculation
        totalPrice = basePrice + additionalServicesPrice
    }
    
    func printCollectedData() {
        print("Car Detailing Order Details:")
        print("----------------------------")
        print("Car Size: \(carSize.rawValue)")
        print("Interior Cleaning: \(interiorCleaning ? "Yes" : "No")")
        print("Exterior Cleaning: \(exteriorCleaning ? "Yes" : "No")")
        print("Additional Services: \(additionalServices.map { $0.rawValue }.joined(separator: ", "))")
        print("Special Instructions: \(specialInstructions)")
        print("Selected Date: \(formattedDate(selectedDate))")
        print("Selected Time: \(formattedTime(selectedTime))")
        print("Base Price: $\(String(format: "%.2f", basePrice))")
        print("Additional Services Price: $\(String(format: "%.2f", additionalServicesPrice))")
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

extension CarSize {
    var basePrice: Double {
        switch self {
        case .standard: return 80
        case .suv: return 110
        case .truck: return 130
        }
    }
    
    var interiorPrice: Double {
        switch self {
        case .standard: return 60
        case .suv: return 70
        case .truck: return 80
        }
    }
    
    var exteriorPrice: Double {
        switch self {
        case .standard: return 25
        case .suv: return 30
        case .truck: return 35
        }
    }
}

extension AdditionalService {
    var price: Double {
        switch self {
        case .engineBayDetailing: return 20
        case .headlightRestoration: return 30
        case .clayBarTreatment: return 30
        case .leatherConditioning: return 20
        case .petHairRemoval: return 30
        }
    }
}
