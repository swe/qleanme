import SwiftUI

enum CleaningType: String, CaseIterable, Identifiable {
    case cleaning = "Cleaning"
    case furRemoval = "Fur Removal"
    case laundry = "Laundry"
    case pressureWashing = "Pressure Washing"
    case ecoCleaning = "Eco Cleaning"
    case junkRemoval = "Junk Removal"
    case carDetailing = "Car Detailing"
    case boatCleaning = "Boat Cleaning"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .cleaning:
            return "Tailored cleaning services to fit every need—standard, deep, move-in/out, and more"
        case .furRemoval:
            return "Say goodbye to stubborn pet hair with expert fur removal for all surfaces"
        case .laundry:
            return "Fresh, clean laundry delivered with care—washing, drying, and folding included"
        case .pressureWashing:
            return "High-powered pressure washing to restore the sparkle to your exterior surfaces"
        case .ecoCleaning:
            return "Green cleaning solutions for a spotless home without harming the environment"
        case .junkRemoval:
            return "Fast and hassle-free junk removal services to clear out your unwanted items"
        case .carDetailing:
            return "Premium car detailing that leaves your vehicle spotless inside and out"
        case .boatCleaning:
            return "Specialized boat cleaning services to keep your vessel looking shipshape"
        }
    }
    
    var iconName: String {
        switch self {
        case .cleaning:
            return "bubbles.and.sparkles.fill"
        case .furRemoval:
            return "pawprint.fill"
        case .laundry:
            return "washer.fill"
        case .pressureWashing:
            return "sprinkler.and.droplets.fill"
        case .ecoCleaning:
            return "leaf.fill"
        case .junkRemoval:
            return "trash.fill"
        case .carDetailing:
            return "car.fill"
        case .boatCleaning:
            return "sailboat.fill"
        }
    }
}
