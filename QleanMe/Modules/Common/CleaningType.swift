import SwiftUI

enum OrderServiceType: String, CaseIterable, Identifiable {
    case cleaning = "Home Cleaning"
    // case furRemoval = "Pet Fur Removal"
    //case laundry = "Laundry"
    //case pressureWashing = "Pressure Wash"
    case ecoCleaning = "Eco Cleaning"
    // case junkRemoval = "Junk Removal"
    //case carDetailing = "Car Detailing"
    // case boatCleaning = "Boat Care"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .cleaning:
            return "bubbles.and.sparkles.fill"
        // case .furRemoval:
        //     return "pawprint.fill"
        // case .laundry:
        //     return "washer.fill"
        // case .pressureWashing:
        //     return "sprinkler.and.droplets.fill"
        case .ecoCleaning:
            return "leaf.fill"
        // case .junkRemoval:
        //     return "trash.fill"
        // case .carDetailing:
        //     return "car.fill"
        // case .boatCleaning:
        //     return "sailboat.fill"
        }
    }
    
    var description: String {
        switch self {
        case .cleaning:
            return "Professional home cleaning tailored to your needs"
        // case .furRemoval:
        //     return "Expert pet hair removal from all surfaces"
        // case .laundry:
        //     return "Wash, dry & fold with free pickup and delivery"
        // case .pressureWashing:
        //     return "Restore surfaces to their original shine"
        case .ecoCleaning:
            return "Green cleaning for an eco-conscious home"
        // case .junkRemoval:
        //     return "Swift removal of unwanted items"
        // case .carDetailing:
        //     return "Premium interior & exterior car care"
        // case .boatCleaning:
        //     return "Complete marine vessel cleaning services"
        }
    }
    
    var gradientColors: [Color] {
        switch self {
        case .cleaning:
            return [Color(hex: 0x2193b0), Color(hex: 0x6dd5ed)] // Ocean Blue
        // case .furRemoval:
        //     return [Color(hex: 0xFF6B6B), Color(hex: 0xFE8F8F)] // Warm Red
        // case .laundry:
        //     return [Color(hex: 0x4776E6), Color(hex: 0x8E54E9)] // Royal Purple
        // case .pressureWashing:
        //     return [Color(hex: 0x11998e), Color(hex: 0x38ef7d)] // Fresh Mint
        case .ecoCleaning:
            return [Color(hex: 0x56ab2f), Color(hex: 0xa8e063)] // Natural Green
        // case .junkRemoval:
        //     return [Color(hex: 0xf46b45), Color(hex: 0xeea849)] // Sunset Orange
        // case .carDetailing:
        //     return [Color(hex: 0x614385), Color(hex: 0x516395)] // Deep Purple
        // case .boatCleaning:
        //  return [Color(hex: 0x36D1DC), Color(hex: 0x5B86E5)] // Ocean Breeze
        }
    }
}

extension OrderServiceType {
    var shortTitle: String {
        switch self {
        case .cleaning:
            return "Cleaning"
        // case .furRemoval:
        //  return "Fur Removal"
        // case .laundry:
        //     return "Laundry"
        // case .pressureWashing:
        //     return "Pressure Wash"
        case .ecoCleaning:
            return "Eco Cleaning"
        // case .junkRemoval:
        //  return "Junk Removal"
        // case .carDetailing:
        //     return "Car Detail"
        // case .boatCleaning:
        //     return "Boat Clean"
        }
    }
}
