import Foundation
import SwiftUI

class ReferralProgramViewModel: ObservableObject {
    let title = "Referral Program"
    let message = "We're crafting an exciting referral program just for you. Be the first to know when it launches!"
    let comingSoonText = "Coming Soon"
    let notifyButtonText = "Notify Me"
    
    @Published var showNotificationConfirmation = false
    
    func notifyMe() {
        // TODO: Implement notification sign-up logic
        showNotificationConfirmation = true
    }
}
