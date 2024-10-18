import Foundation
import Combine

class LoginViewModel: ObservableObject {
    @Published var phoneNumber: String = ""
    @Published var isValidPhoneNumber: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showVerificationView: Bool = false
    
    var formattedPhoneNumber: String {
        return "+1" + phoneNumber.filter { $0.isNumber }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        $phoneNumber
            .map { self.isValidPhoneNumber($0) }
            .assign(to: \.isValidPhoneNumber, on: self)
            .store(in: &cancellables)
    }
    
    func formatPhoneNumber() {
        let digitsOnly = phoneNumber.filter { $0.isNumber }
        let maskedNumber = format(phoneNumber: digitsOnly)
        if maskedNumber != phoneNumber {
            phoneNumber = maskedNumber
        }
    }
    
    private func format(phoneNumber: String) -> String {
        guard phoneNumber.count <= 10 else { return String(phoneNumber.prefix(10)) }
        var result = ""
        let mask = "(XXX) XXX-XXXX"
        var index = phoneNumber.startIndex
        
        for ch in mask where index < phoneNumber.endIndex {
            if ch == "X" {
                result.append(phoneNumber[index])
                index = phoneNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
    
    private func isValidPhoneNumber(_ number: String) -> Bool {
        let digitsOnly = number.filter { $0.isNumber }
        return digitsOnly.count == 10
    }
    
    func validateAndProceed() {
        guard isValidPhoneNumber else { return }
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let result = try await NetworkManager.shared.checkUserExistence(phoneNumber: formattedPhoneNumber)
                DispatchQueue.main.async {
                    self.isLoading = false
                    print(result)
                    self.showVerificationView = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "An error occurred: \(error.localizedDescription)"
                }
            }
        }
    }
}
