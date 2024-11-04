//
//  AppCoordinatorView.swift
//  QleanMe
//
//  Created by weirdnameofadmin on 2024-11-04.
//


import SwiftUI
import Combine

// Main App Coordinator View
struct AppCoordinatorView: View {
    @StateObject private var coordinator = AppCoordinator()
    
    var body: some View {
        Group {
            if coordinator.isLoading {
                splashScreen
            } else {
                if coordinator.isAuthenticated {
                    RegisteredUserDashboardView()
                } else {
                    WelcomeView()
                }
            }
        }
        .animation(.easeInOut, value: coordinator.isAuthenticated)
        .animation(.easeInOut, value: coordinator.isLoading)
    }
    
    private var splashScreen: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "bubbles.and.sparkles.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(hex: 0x4776E6),
                                Color(hex: 0x8E54E9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
    }
}

// App Coordinator
class AppCoordinator: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    private let authManager: AuthenticationManager
    private let networkManager: NetworkManager
    
    init(authManager: AuthenticationManager = .shared,
         networkManager: NetworkManager = .shared) {
        self.authManager = authManager
        self.networkManager = networkManager
        
        setupBindings()
        checkAuthenticationStatus()
    }
    
    private func setupBindings() {
        authManager.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                self?.isAuthenticated = isAuthenticated
            }
            .store(in: &cancellables)
    }
    
    private func checkAuthenticationStatus() {
        Task {
            do {
                // Check if we have stored phone number
                if let phoneNumber = UserDefaults.standard.string(forKey: "userPhoneNumber") {
                    // Verify the stored phone number with the server
                    _ = try await networkManager.checkUserExistence(phoneNumber: phoneNumber)
                    
                    await MainActor.run {
                        self.isAuthenticated = true
                        self.isLoading = false
                    }
                } else {
                    await MainActor.run {
                        self.isAuthenticated = false
                        self.isLoading = false
                    }
                }
            } catch {
                // If there's an error (e.g., network error, invalid token)
                // we log the user out and show the welcome screen
                print("Authentication check failed: \(error)")
                
                await MainActor.run {
                    self.handleAuthenticationFailure()
                }
            }
        }
    }
    
    private func handleAuthenticationFailure() {
        // Clear stored credentials
        UserDefaults.standard.removeObject(forKey: "userPhoneNumber")
        UserDefaults.standard.synchronize()
        
        // Update UI state
        self.isAuthenticated = false
        self.isLoading = false
    }
}
