import Foundation
import Combine
import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var notificationsEnabled: Bool
    @Published var autoTippingEnabled: Bool
    @Published var autoTipPercentage: Double
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        self.notificationsEnabled = userDefaults.bool(forKey: "notificationsEnabled")
        self.autoTippingEnabled = userDefaults.bool(forKey: "autoTippingEnabled")
        self.autoTipPercentage = userDefaults.double(forKey: "autoTipPercentage")
        
        if self.autoTipPercentage == 0 {
            self.autoTipPercentage = 15 // Default to 15% if not set
        }
    }
    
    func updateNotifications(_ enabled: Bool) {
        notificationsEnabled = enabled
        userDefaults.set(enabled, forKey: "notificationsEnabled")
    }
    
    func updateAutoTipping(_ enabled: Bool) {
        autoTippingEnabled = enabled
        userDefaults.set(enabled, forKey: "autoTippingEnabled")
    }
    
    func updateAutoTipPercentage(_ percentage: Double) {
        autoTipPercentage = percentage
        userDefaults.set(percentage, forKey: "autoTipPercentage")
    }
}
