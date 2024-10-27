import Foundation
import Combine

@MainActor
class OrderHomeCleaningViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedCleaningType: HomeCleaningType = .regular
    @Published var numberOfBedrooms: Int = 1
    @Published var numberOfBathrooms: Int = 1
    @Published var numberOfRooms: Int = 1
    @Published var selectedSize: PropertySize = .small
    @Published var selectedAdditionalServices: Set<UUID> = []
    
    // MARK: - Computed Properties
    var basePrice: Decimal {
        selectedCleaningType.basePrice
    }
    
    var roomsPrice: Decimal {
        let bedroomPrice = Decimal(numberOfBedrooms - 1) * Decimal(string: "20.00")!
        let bathroomPrice = Decimal(numberOfBathrooms - 1) * Decimal(string: "25.00")!
        let otherRoomsPrice = Decimal(numberOfRooms - 1) * Decimal(string: "15.00")!
        
        return bedroomPrice + bathroomPrice + otherRoomsPrice
    }
    
    var sizeMultiplier: Decimal {
        selectedSize.priceMultiplier
    }
    
    var additionalServicesPrice: Decimal {
        AdditionalService.available
            .filter { selectedAdditionalServices.contains($0.id) }
            .reduce(Decimal.zero) { $0 + $1.price }
    }
    
    var totalPrice: Decimal {
        (basePrice + roomsPrice) * sizeMultiplier + additionalServicesPrice
    }
    
    // MARK: - Methods
    func toggleAdditionalService(_ serviceId: UUID) {
        if selectedAdditionalServices.contains(serviceId) {
            selectedAdditionalServices.remove(serviceId)
        } else {
            selectedAdditionalServices.insert(serviceId)
        }
    }
    
    func incrementValue(for type: RoomType) {
        switch type {
        case .bedroom:
            if numberOfBedrooms < 10 {
                numberOfBedrooms += 1
            }
        case .bathroom:
            if numberOfBathrooms < 10 {
                numberOfBathrooms += 1
            }
        case .other:
            if numberOfRooms < 10 {
                numberOfRooms += 1
            }
        }
    }
    
    func decrementValue(for type: RoomType) {
        switch type {
        case .bedroom:
            if numberOfBedrooms > 1 {
                numberOfBedrooms -= 1
            }
        case .bathroom:
            if numberOfBathrooms > 1 {
                numberOfBathrooms -= 1
            }
        case .other:
            if numberOfRooms > 1 {
                numberOfRooms -= 1
            }
        }
    }
}

enum RoomType {
    case bedroom
    case bathroom
    case other
}
