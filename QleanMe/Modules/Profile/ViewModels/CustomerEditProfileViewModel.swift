import Foundation
import Combine
import SwiftUI

class CustomerEditProfileViewModel: ObservableObject {
    @Published var profileImage: UIImage?
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var phoneNumber: String = ""
    @Published var addresses: [Address] = []
    @Published var paymentMethods: [PaymentMethod] = []
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showImagePicker: Bool = false
    @Published var showAddressForm: Bool = false
    @Published var showPaymentMethodForm: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchUserData()
    }
    
    func fetchUserData() {
        isLoading = true
        // TODO: Implement actual data fetching from Supabase
        // For now, we'll use placeholder data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.fullName = "John Doe"
            self.email = "john.doe@example.com"
            self.phoneNumber = "+16045551234"
            self.addresses = [
                Address(id: UUID().uuidString, street: "123 Main St", city: "Vancouver", province: "BC", postalCode: "V6B 1A1"),
                Address(id: UUID().uuidString, street: "456 Oak Ave", city: "Victoria", province: "BC", postalCode: "V8W 1N6")
            ]
            self.paymentMethods = [
                PaymentMethod(id: UUID().uuidString, type: .applePay),
                PaymentMethod(id: UUID().uuidString, type: .creditCard, last4: "1234")
            ]
            self.isLoading = false
        }
    }
    
    func updateProfile() {
        isLoading = true
        // TODO: Implement actual profile update logic using Supabase
        // For now, we'll simulate a network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Simulating successful update
            self.isLoading = false
            // TODO: Handle successful update (e.g., show success message, navigate back)
        }
    }
    
    func addAddress(_ address: Address) {
        guard addresses.count < 10 else {
            errorMessage = "Maximum of 10 addresses allowed"
            return
        }
        addresses.append(address)
    }
    
    func removeAddress(at index: Int) {
        addresses.remove(at: index)
    }
    
    func addPaymentMethod(_ paymentMethod: PaymentMethod) {
        paymentMethods.append(paymentMethod)
    }
    
    func removePaymentMethod(at index: Int) {
        paymentMethods.remove(at: index)
    }
    
    func formatPhoneNumber(_ phone: String) -> String {
        let cleanPhoneNumber = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "+X (XXX) XXX-XXXX"
        var result = ""
        var index = cleanPhoneNumber.startIndex
        var maskIndex = mask.startIndex

        while maskIndex < mask.endIndex {
            if mask[maskIndex] == "X" {
                if index < cleanPhoneNumber.endIndex {
                    result.append(cleanPhoneNumber[index])
                    index = cleanPhoneNumber.index(after: index)
                } else {
                    break
                }
            } else {
                result.append(mask[maskIndex])
            }
            maskIndex = mask.index(after: maskIndex)
        }
        return result
    }
}

struct Address: Identifiable {
    let id: String
    var street: String
    var city: String
    var province: String
    var postalCode: String
}

struct PaymentMethod: Identifiable {
    let id: String
    let type: PaymentType
    var last4: String?
    
    enum PaymentType {
        case applePay
        case creditCard
    }
}
