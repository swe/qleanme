import Foundation
import Combine
import SwiftUI
import MessageUI

class CustomerProfileViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var phoneNumber: String = ""
    @Published var profileImage: String = ""
    @Published var completedOrders: Int = 0
    @Published var averageRating: Double = 0.0
    @Published var showReferralProgram: Bool = false
    @Published var showMailComposer: Bool = false
    @Published var isLoggingOut: Bool = false
    @Published var showLogoutConfirmation: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var shouldNavigateToWelcome: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let networkManager: NetworkManager
    private let authManager: AuthenticationManager
    
    init(networkManager: NetworkManager = .shared, authManager: AuthenticationManager = .shared) {
        self.networkManager = networkManager
        self.authManager = authManager
        fetchUserData()
    }
    
    func fetchUserData() {
        isLoading = true
        
        Task {
            do {
                let userPhone = UserDefaults.standard.string(forKey: "userPhoneNumber") ?? ""
                let profile = try await networkManager.fetchUserProfile(phoneNumber: userPhone)
                
                await MainActor.run {
                    userName = profile.fullName
                    phoneNumber = profile.phoneNumber
                    profileImage = profile.photoUrl
                    completedOrders = profile.amountOfOrders
                    averageRating = profile.amountOfOrders > 0
                        ? Double(profile.totalRating) / Double(profile.amountOfOrders)
                        : 0.0
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
    
    var formattedPhoneNumber: String {
        let cleaned = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "+X (XXX) XXX-XXXX"
        var result = ""
        var index = cleaned.startIndex
        for ch in mask where index < cleaned.endIndex {
            if ch == "X" {
                result.append(cleaned[index])
                index = cleaned.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
    
    func navigateToProfileDetails() {
        // TODO: Implement navigation to profile details
        print("Navigating to profile details")
    }
    
    func navigateToSettings() {
        // TODO: Implement navigation to settings
        print("Navigating to settings")
    }
    
    func navigateToAbout() {
        // TODO: Implement navigation to about
        print("Navigating to about")
    }
    
    func navigateToFAQ() {
        // TODO: Implement navigation to FAQ
        print("Navigating to FAQ")
    }
    
    func navigateToSupport() {
        if MFMailComposeViewController.canSendMail() {
            showMailComposer = true
        } else {
            print("Device cannot send emails")
        }
    }
    
    func navigateToReferralProgram() {
        showReferralProgram = true
    }
    
    func initiateLogout() {
        showLogoutConfirmation = true
    }
    
    func logout() {
        isLoggingOut = true
        
        Task {
            do {
                // Clear all user defaults
                UserDefaults.standard.removeObject(forKey: "userPhoneNumber")
                UserDefaults.standard.synchronize()
                
                // Reset all local state
                userName = ""
                phoneNumber = ""
                profileImage = ""
                completedOrders = 0
                averageRating = 0.0
                
                // Update auth state
                try await authManager.signOut()
                
                await MainActor.run {
                    isLoggingOut = false
                    withAnimation(.easeInOut(duration: 0.3)) {
                        shouldNavigateToWelcome = true
                    }
                }
            } catch {
                await MainActor.run {
                    isLoggingOut = false
                    errorMessage = "Failed to logout: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func cancelLogout() {
        showLogoutConfirmation = false
    }
}
