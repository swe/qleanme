import SwiftUI
import Combine

enum OrderCleaningType: String, CaseIterable, Identifiable {
    case baseCleaning = "Base Cleaning"
    case carDetailing = "Car Detailing"
    case laundry = "Laundry"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .baseCleaning: return "house.fill"
        case .carDetailing: return "car.fill"
        case .laundry: return "washer.fill"
        }
    }
    
    var description: String {
        switch self {
        case .baseCleaning: return "Standard home cleaning service"
        case .carDetailing: return "Comprehensive car cleaning and detailing"
        case .laundry: return "Wash, dry, and fold laundry service"
        }
    }
}

class OrderCreationViewModel: ObservableObject {
    @Published var selectedCleaningType: OrderCleaningType?
    @Published var isNextButtonActive: Bool = false
    @Published var shouldNavigateToDetail: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        $selectedCleaningType
            .map { $0 != nil }
            .assign(to: \.isNextButtonActive, on: self)
            .store(in: &cancellables)
    }
    
    func selectCleaningType(_ type: OrderCleaningType) {
        selectedCleaningType = type
    }
    
    func proceedToNextStep() {
        guard selectedCleaningType != nil else { return }
        shouldNavigateToDetail = true
    }
}
