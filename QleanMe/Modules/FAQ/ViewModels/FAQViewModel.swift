import Foundation
import Combine

@MainActor
class FAQViewModel: ObservableObject {
    @Published var faqs: [FAQ] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchFAQs() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                faqs = try await NetworkManager.shared.fetchFAQs()
                isLoading = false
            } catch {
                errorMessage = "Failed to load FAQs: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
}
