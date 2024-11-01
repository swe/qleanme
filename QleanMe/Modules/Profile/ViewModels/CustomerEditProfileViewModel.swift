import Foundation
import Combine
import SwiftUI

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

class CustomerEditProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var profileImage: UIImage?
    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var phoneNumber: String = ""
    @Published var notificationsEnabled: Bool = false
    @Published var addresses: [Address] = []
    @Published var paymentMethods: [PaymentMethod] = []
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showImagePicker: Bool = false
    @Published var showAddressForm: Bool = false
    @Published var showPaymentMethodForm: Bool = false
    @Published var showSuccessAlert: Bool = false
    @Published var hasChanges: Bool = false
    @Published var isValidEmail: Bool = true
    @Published var isValidName: Bool = true
    @Published private(set) var validationErrors: [ValidationError] = []
    
    // MARK: - Private Properties
    private var userId: Int?
    private var originalProfile: UserProfile?
    private var cancellables = Set<AnyCancellable>()
    private let networkManager: NetworkManager
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Validation Types
    enum ValidationError: Identifiable {
        case emptyName
        case invalidEmail
        case invalidPhoneNumber
        
        var id: String {
            switch self {
            case .emptyName: return "emptyName"
            case .invalidEmail: return "invalidEmail"
            case .invalidPhoneNumber: return "invalidPhoneNumber"
            }
        }
        
        var message: String {
            switch self {
            case .emptyName:
                return "Name cannot be empty"
            case .invalidEmail:
                return "Please enter a valid email address"
            case .invalidPhoneNumber:
                return "Please enter a valid phone number"
            }
        }
    }
    
    // MARK: - Initialization
    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
        setupPublishers()
        fetchUserData()
    }
    
    // MARK: - Private Methods
    private func setupPublishers() {
        Publishers.CombineLatest3($fullName, $email, $notificationsEnabled)
            .dropFirst()
            .sink { [weak self] name, email, notifications in
                guard let self = self, let original = self.originalProfile else { return }
                
                self.hasChanges = name.trimmingCharacters(in: .whitespacesAndNewlines) != original.fullName ||
                email.trimmingCharacters(in: .whitespacesAndNewlines) != original.email ||
                notifications != original.notificationsEnabled
                
                self.validateForm()
            }
            .store(in: &cancellables)
        
        $email
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] email in
                self?.validateEmail(email)
            }
            .store(in: &cancellables)
        
        $fullName
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] name in
                self?.validateName(name)
            }
            .store(in: &cancellables)
    }
    
    private func validateForm() {
        var errors: [ValidationError] = []
        
        if fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(.emptyName)
            isValidName = false
        } else {
            isValidName = true
        }
        
        if !isValidEmailFormat(email) {
            errors.append(.invalidEmail)
            isValidEmail = false
        } else {
            isValidEmail = true
        }
        
        validationErrors = errors
    }
    
    private func validateName(_ name: String) {
        isValidName = !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        validateForm()
    }
    
    private func validateEmail(_ email: String) {
        isValidEmail = isValidEmailFormat(email)
        validateForm()
    }
    
    private func isValidEmailFormat(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - Public Methods
    func fetchUserData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                guard let userPhone = userDefaults.string(forKey: "userPhoneNumber") else {
                    throw NetworkError.invalidData("No phone number found. Please log in again.")
                }
                
                let profile = try await networkManager.fetchUserProfile(phoneNumber: userPhone)
                
                await MainActor.run {
                    self.userId = profile.id
                    self.originalProfile = profile
                    self.fullName = profile.fullName
                    self.email = profile.email
                    self.phoneNumber = profile.phoneNumber
                    self.notificationsEnabled = profile.notificationsEnabled
                    // Mock data for development
                    self.addresses = [
                        Address(id: UUID().uuidString, street: "123 Main St", city: "Vancouver", province: "BC", postalCode: "V6B 1A1"),
                        Address(id: UUID().uuidString, street: "456 Oak Ave", city: "Victoria", province: "BC", postalCode: "V8W 1N6")
                    ]
                    self.paymentMethods = [
                        PaymentMethod(id: UUID().uuidString, type: .applePay),
                        PaymentMethod(id: UUID().uuidString, type: .creditCard, last4: "1234")
                    ]
                    self.validateForm()
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = self.handleError(error)
                    self.isLoading = false
                }
            }
        }
    }
    
    func saveProfile() {
        guard hasChanges else { return }
        guard validateBeforeSave() else { return }
        guard let userId = userId else {
            errorMessage = "Unable to identify user. Please log in again."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                if email.trimmingCharacters(in: .whitespacesAndNewlines) != originalProfile?.email {
                    let isAvailable = try await networkManager.isEmailAvailable(email, excludingUserId: userId)
                    guard isAvailable else {
                        throw NetworkError.validationError("This email is already in use")
                    }
                }
                
                let updatedProfile = try await networkManager.updateUserProfile(
                    userId: userId,
                    fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    notificationsEnabled: notificationsEnabled
                )
                
                await MainActor.run {
                    self.originalProfile = updatedProfile
                    self.hasChanges = false
                    self.showSuccessAlert = true
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = self.handleError(error)
                    self.isLoading = false
                }
            }
        }
    }
    
    func addAddress(_ address: Address) {
        guard addresses.count < 10 else {
            errorMessage = "Maximum of 10 addresses allowed"
            return
        }
        addresses.append(address)
        hasChanges = true
    }
    
    func removeAddress(at index: Int) {
        addresses.remove(at: index)
        hasChanges = true
    }
    
    func addPaymentMethod(_ paymentMethod: PaymentMethod) {
        paymentMethods.append(paymentMethod)
        hasChanges = true
    }
    
    func removePaymentMethod(at index: Int) {
        paymentMethods.remove(at: index)
        hasChanges = true
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
    
    // MARK: - Helper Methods
    private func validateBeforeSave() -> Bool {
        validateForm()
        
        guard validationErrors.isEmpty else {
            errorMessage = validationErrors.first?.message
            return false
        }
        
        return true
    }
    
    private func handleError(_ error: Error) -> String {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .validationError(let message),
                 .updateError(let message),
                 .serverError(let message),
                 .invalidData(let message):
                return message
            default:
                return "An unexpected error occurred"
            }
        }
        return error.localizedDescription
    }
    
    // MARK: - Computed Properties
    var canSave: Bool {
        hasChanges && validationErrors.isEmpty && !isLoading
    }
    
    var formattedErrorMessage: String? {
        if !validationErrors.isEmpty {
            return validationErrors.map { $0.message }.joined(separator: "\n")
        }
        return errorMessage
    }
}
