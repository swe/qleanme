
import Foundation

enum HomeCleaningType: String, CaseIterable, Identifiable {
    case regular = "Regular Cleaning"
    case deep = "Deep Cleaning"
    case moveInOut = "Move In/Out Cleaning"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .regular:
            return "Standard cleaning service for maintaining a tidy home"
        case .deep:
            return "Thorough cleaning including hard-to-reach areas and detailed attention"
        case .moveInOut:
            return "Comprehensive cleaning for moving transitions"
        }
    }
    
    var iconName: String {
        switch self {
        case .regular:
            return "sparkles"
        case .deep:
            return "bubbles.and.sparkles"
        case .moveInOut:
            return "building.2"
        }
    }
    
    var basePrice: Decimal {
        switch self {
        case .regular:
            return Decimal(string: "129.99")!
        case .deep:
            return Decimal(string: "199.99")!
        case .moveInOut:
            return Decimal(string: "249.99")!
        }
    }
}

enum PropertySize: String, CaseIterable, Identifiable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .small:
            return "Up to 1,000 sq ft"
        case .medium:
            return "1,000 - 2,000 sq ft"
        case .large:
            return "2,000+ sq ft"
        }
    }
    
    var priceMultiplier: Decimal {
        switch self {
        case .small:
            return Decimal(string: "1.0")!
        case .medium:
            return Decimal(string: "1.3")!
        case .large:
            return Decimal(string: "1.6")!
        }
    }
}

struct AdditionalService: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let price: Decimal
    let iconName: String
    
    static let available: [AdditionalService] = [
        AdditionalService(
            name: "Refrigerator Revival",
            description: "Deep cleaning and organizing your fridge, making it sparkle inside and out",
            price: Decimal(string: "35.00")!,
            iconName: "refrigerator.fill"
        ),
        AdditionalService(
            name: "Oven Transformation",
            description: "Thorough cleaning of your oven, removing tough grease and baked-on residue",
            price: Decimal(string: "45.00")!,
            iconName: "oven.fill"
        ),
        AdditionalService(
            name: "Cabinet Refresh",
            description: "Detailed cleaning of cabinet interiors and exteriors, including organization",
            price: Decimal(string: "40.00")!,
            iconName: "cabinet.fill"
        ),
        AdditionalService(
            name: "Crystal Clear Windows",
            description: "Interior window cleaning, including frames and sills",
            price: Decimal(string: "50.00")!,
            iconName: "window.ceiling"
        ),
        AdditionalService(
            name: "Carpet Care Plus",
            description: "Deep carpet cleaning and stain removal for high-traffic areas",
            price: Decimal(string: "60.00")!,
            iconName: "square.grid.2x2.fill"
        ),
        AdditionalService(
            name: "Dish & Cutlery Care",
            description: "Washing, drying, and organizing dishes and cutlery",
            price: Decimal(string: "20.00")!,
            iconName: "dishwasher.fill"
        ),
        AdditionalService(
            name: "Microwave Makeover",
            description: "Detailed cleaning of your microwave inside and out",
            price: Decimal(string: "20.00")!,
            iconName: "microwave.fill"
        ),
        AdditionalService(
            name: "Closet Organization",
            description: "Professional organizing and cleaning of your closet space",
            price: Decimal(string: "45.00")!,
            iconName: "tshirt.fill"
        ),
        AdditionalService(
            name: "Bathroom Brilliance",
            description: "Intensive cleaning of bathtub, shower, and surrounding areas",
            price: Decimal(string: "35.00")!,
            iconName: "bathtub.fill"
        ),
        AdditionalService(
            name: "Toilet Deep Clean",
            description: "Thorough sanitization and cleaning of toilet and surrounding area",
            price: Decimal(string: "25.00")!,
            iconName: "toilet.fill"
        )
    ]
}
