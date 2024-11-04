import Foundation
import Combine

class AuthenticationManager {
    static let shared = AuthenticationManager()
    
    @Published private(set) var isAuthenticated: Bool
    private let userDefaults = UserDefaults.standard
    
    private init() {
        self.isAuthenticated = userDefaults.string(forKey: "userPhoneNumber") != nil
    }
    
    func signIn(phoneNumber: String) {
        userDefaults.set(phoneNumber, forKey: "userPhoneNumber")
        userDefaults.synchronize()
        isAuthenticated = true
    }
    
    func signOut() async throws {
        // Clear all authentication-related data
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
        defaults.synchronize()
        
        // Reset authentication state
        isAuthenticated = false
        
        // Simulate network delay for logout
        try await Task.sleep(nanoseconds: 500_000_000)
    }
    
    func checkAuthenticationStatus() -> Bool {
        return isAuthenticated
    }
}
