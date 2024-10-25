import Foundation
import Combine
import UserNotifications
import UIKit

class RegistrationViewModel: ObservableObject {
    @Published var email = ""
    @Published var fullName = ""
    @Published var notificationsEnabled = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isRegistrationComplete = false
    
    @Published var isEmailValid = false
    @Published var isFullNameValid = false
    
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    private let networkManager = NetworkManager.shared
    private let phoneNumber: String
    
    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
        setupValidation()
    }
    
    private func setupValidation() {
        // Email validation
        $email
            .map { email -> Bool in
                let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
                return emailPredicate.evaluate(with: email)
            }
            .assign(to: &$isEmailValid)
        
        // Full name validation
        $fullName
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .assign(to: &$isFullNameValid)
    }
    
    var canProceed: Bool {
        isEmailValid && isFullNameValid
    }
    
    func register() {
        guard canProceed else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Update notification settings if enabled
                if notificationsEnabled {
                    try await requestNotificationPermissions()
                }
                
                // Save notification preference to UserDefaults
                userDefaults.set(notificationsEnabled, forKey: "notificationsEnabled")
                
                // Register user in Supabase
                try await networkManager.registerUser(
                    fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    phoneNumber: phoneNumber,
                    notificationsEnabled: notificationsEnabled
                )
                
                await MainActor.run {
                    isRegistrationComplete = true
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Registration failed: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    private func requestNotificationPermissions() async throws {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        guard settings.authorizationStatus != .authorized else { return }
        
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        if !granted {
            throw NSError(
                domain: "NotificationError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Notification permission denied"]
            )
        }
        
        await MainActor.run {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}
