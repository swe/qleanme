import Foundation
import Combine
import SwiftUI

enum NavigationType: Identifiable {
    case registeredUserDashboard
    case contractorDashboard
    case registration
    
    var id: String {
        switch self {
        case .registeredUserDashboard:
            return "registeredUserDashboard"
        case .contractorDashboard:
            return "contractorDashboard"
        case .registration:
            return "registration"
        }
    }
}

class VerificationViewModel: ObservableObject {
    @Published var code: [String] = Array(repeating: "", count: 6)
    @Published var isVerified = false
    @Published var isCodeIncorrect = false
    @Published var isLoading = false
    @Published var navigationType: NavigationType?
    
    let phoneNumber: String
    let formattedPhoneNumber: String
    
    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
        self.formattedPhoneNumber = PhoneNumberFormatter.formatForE164(phoneNumber)
    }
    
    var isValidCode: Bool {
        code.joined().count == 6
    }
    
    func bindingForDigit(at index: Int) -> Binding<String> {
        return Binding<String>(
            get: { self.code[index] },
            set: { newValue in
                let filtered = newValue.filter { $0.isNumber }
                if filtered.count <= 1 {
                    self.code[index] = filtered
                } else if filtered.count > 1 {
                    // If pasting multiple digits, distribute them across fields
                    let digits = Array(filtered)
                    for i in 0..<min(digits.count, 6 - index) {
                        self.code[index + i] = String(digits[i])
                    }
                }
                self.isCodeIncorrect = false // Reset error state when input changes
            }
        )
    }
    
    func verifyCode() {
        guard isValidCode else { return }
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let fullCode = self.code.joined()
            if fullCode == "123456" {
                // Correct verification code
                self.isVerified = true
                self.isCodeIncorrect = false
                self.determineNavigationType()
            } else {
                // Incorrect code
                self.isCodeIncorrect = true
                
                // Clear the code
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.clearCode()
                }
            }
            self.isLoading = false
        }
    }
    
    private func determineNavigationType() {
        switch NetworkManager.shared.currentUserType {
        case .user:
            navigationType = .registeredUserDashboard
        case .worker:
            navigationType = .contractorDashboard
        case .newUser:
            navigationType = .registration
        }
    }
    
    func clearCode() {
        for i in 0..<6 {
            code[i] = ""
        }
    }
    
    func resendCode() {
        isLoading = true
        
        // Simulate network delay for resending code
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // TODO: Implement actual code resend logic here
            print("Resending verification code to: \(self.formattedPhoneNumber)")
            self.clearCode()
            self.isCodeIncorrect = false
            self.isLoading = false
        }
    }
}

struct PhoneNumberFormatter {
    static func formatForE164(_ phoneNumber: String) -> String {
        let cleanedNumber = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        return "+1\(cleanedNumber)"
    }
}
