import Foundation
import Combine
import SwiftUI

enum CleaningSupplies {
    case own
    case bring
}

enum AddressSelectionType {
    case map
    case saved
}

@MainActor
class HomeCleaningAdditionalViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var hasPets: Bool = false
    @Published var petDetails: String = ""
    @Published var cleaningSupplies: CleaningSupplies = .own
    @Published var hasVacuum: Bool = true
    @Published var location: String = ""
    @Published var specialInstructions: String = ""
    @Published var showLocationPicker = false
    @Published var showSavedAddresses = false
    @Published var shouldNavigateToReview = false
    @Published var showAddressAlert = false
    
    // MARK: - Properties
    let cleaningDetails: OrderHomeCleaningViewModel
    
    // MARK: - Computed Properties
    var isValid: Bool {
        if hasPets && petDetails.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }
        if location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }
        return true
    }
    
    // MARK: - Initialization
    init(cleaningDetails: OrderHomeCleaningViewModel) {
        self.cleaningDetails = cleaningDetails
    }
    
    // MARK: - Public Methods
    func handleAddressSelection(_ type: AddressSelectionType) {
        switch type {
        case .map:
            showLocationPicker = true
        case .saved:
            showSavedAddresses = true
        }
    }
    
    func showAddressOptions() {
        showAddressAlert = true
    }
    
    func navigateToReview() {
        guard isValid else { return }
        shouldNavigateToReview = true
    }
    
    func popToRoot() {
        shouldNavigateToReview = false
    }
    
    func setLocation(_ address: String) {
        location = address
        showLocationPicker = false
        showSavedAddresses = false
    }
    
    func createOrderSummary() -> [String: Any] {
        var summary: [String: Any] = [
            "cleaningType": cleaningDetails.selectedCleaningType.rawValue,
            "numberOfBedrooms": cleaningDetails.numberOfBedrooms,
            "numberOfBathrooms": cleaningDetails.numberOfBathrooms,
            "numberOfRooms": cleaningDetails.numberOfRooms,
            "propertySize": cleaningDetails.selectedSize.rawValue,
            "totalPrice": NSDecimalNumber(decimal: cleaningDetails.totalPrice).doubleValue,
            "additionalDetails": [
                "hasPets": hasPets,
                "cleaningSupplies": cleaningSupplies.description,
                "hasVacuum": hasVacuum,
                "location": location,
                "specialInstructions": specialInstructions.trimmingCharacters(in: .whitespacesAndNewlines)
            ]
        ]
        
        if !cleaningDetails.selectedAdditionalServices.isEmpty {
            summary["additionalServices"] = cleaningDetails.selectedAdditionalServices
        }
        
        if hasPets {
            summary["petDetails"] = petDetails.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return summary
    }
}

// MARK: - Custom String Convertible
extension CleaningSupplies: CustomStringConvertible {
    var description: String {
        switch self {
        case .own:
            return "Customer's supplies"
        case .bring:
            return "Bring supplies"
        }
    }
}
