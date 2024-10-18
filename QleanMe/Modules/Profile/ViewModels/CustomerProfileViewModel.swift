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
    
    let placeholderImageURL = "https://i.alleksy.com/qlean/photoPlaceholder.png"
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchUserData()
    }
    
    private func fetchUserData() {
        // TODO: Implement actual data fetching from Supabase
        // For now, we'll use placeholder data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.userName = "John Peterson"
            self.phoneNumber = "+16045551234"
            self.profileImage = "" // Empty string to simulate no profile picture
            self.completedOrders = 5
            self.averageRating = 4.8
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
            // Handle the case where the device can't send emails
            print("Device cannot send emails")
            // You might want to show an alert to the user here
        }
    }
    
    func navigateToReferralProgram() {
        showReferralProgram = true
    }
    
    func logout() {
        isLoggingOut = true
        // TODO: Implement actual logout logic using Supabase
        // For now, we'll simulate a network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Clear user data
            self.userName = ""
            self.phoneNumber = ""
            self.profileImage = ""
            self.completedOrders = 0
            self.averageRating = 0.0
            
            // TODO: Navigate to the WelcomeView or LoginView
            print("User logged out successfully")
            self.isLoggingOut = false
            
            // In a real app, you would use your app's navigation system to return to the login or welcome screen
            // For example, if using the new SwiftUI navigation system:
            // navigationPath.removeLast(navigationPath.count)
        }
    }
}
