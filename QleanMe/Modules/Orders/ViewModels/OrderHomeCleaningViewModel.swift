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
    
    // MARK: - Property Size Formatting
    var formattedPropertySizeRange: String {
        switch selectedSize {
        case .small:
            return "0 - 600 sq ft"
        case .medium:
            return "601 - 1,000 sq ft"
        case .large:
            return "1,001+ sq ft"
        }
    }
    
    // MARK: - Duration Calculation
    var estimatedDuration: Int {
        // Base duration in minutes
        var duration: Int = 0
        
        // Base duration by cleaning type
        switch selectedCleaningType {
        case .regular:
            duration = 120 // 2 hours base
        case .deep:
            duration = 240 // 4 hours base
        case .moveInOut:
            duration = 360 // 6 hours base
        }
        
        // Add time for rooms
        duration += (numberOfBedrooms - 1) * 30  // 30 mins per additional bedroom
        duration += (numberOfBathrooms - 1) * 45 // 45 mins per additional bathroom
        duration += (numberOfRooms - 1) * 20     // 20 mins per additional room
        
        // Adjust for property size
        switch selectedSize {
        case .small:
            duration = Int(Double(duration) * 1.3) // 30% more time
            //duration = duration
        case .medium:
            duration = Int(Double(duration) * 1.3) // 30% more time
        case .large:
            duration = Int(Double(duration) * 1.5) // 50% more time
        }
        
        // Add time for additional services
        let additionalServicesCount = selectedAdditionalServices.count
        duration += additionalServicesCount * 30  // 30 mins per additional service
        
        return duration
    }
    
    // MARK: - Room Description
    var formattedRoomsSubtype: String {
        return "\(numberOfBedrooms) bedrooms, \(numberOfBathrooms) bathrooms, \(numberOfRooms) other rooms, \(formattedPropertySizeRange)"
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
    
    // MARK: - Selected Services Information
    var selectedServices: [AdditionalService] {
        AdditionalService.available.filter { selectedAdditionalServices.contains($0.id) }
    }
}

enum RoomType {
    case bedroom
    case bathroom
    case other
}
