import SwiftUI

struct RegistrationView: View {
    let phoneNumber: String
    @StateObject private var viewModel: RegistrationViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
        self._viewModel = StateObject(wrappedValue: RegistrationViewModel(phoneNumber: phoneNumber))
    }
    
    private let gradientColors = [Color(hex: 0x4776E6), Color(hex: 0x8E54E9)]
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 24) {
                        welcomeSection
                        formSection
                        notificationsSection
                        registerButton
                    }
                    .padding()
                }
                
                if viewModel.isLoading {
                    LoadingView()
                }
            }
            .navigationTitle("Registration")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .navigationDestination(isPresented: $viewModel.isRegistrationComplete) {
                RegisteredUserDashboardView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    private var welcomeSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Welcome to QleanMe!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Please fill in your details to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }
    
    private var formSection: some View {
        VStack(spacing: 20) {
            InputField(
                title: "Full Name",
                text: $viewModel.fullName,
                icon: "person.fill",
                placeholder: "Enter your full name",
                isValid: viewModel.isFullNameValid
            )
            
            InputField(
                title: "Email",
                text: $viewModel.email,
                icon: "envelope.fill",
                placeholder: "Enter your email",
                keyboardType: .emailAddress,
                autocapitalization: .never,
                isValid: viewModel.isEmailValid
            )
        }
    }
    
    private var notificationsSection: some View {
        VStack(spacing: 12) {
            Toggle(isOn: $viewModel.notificationsEnabled) {
                HStack {
                    Image(systemName: "bell.badge.fill")
                        .foregroundColor(gradientColors[0])
                    
                    VStack(alignment: .leading) {
                        Text("Enable Notifications")
                            .font(.headline)
                        Text("Get updates about your orders")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            
            if viewModel.notificationsEnabled {
                Text("You'll receive notifications about order updates, special offers, and more!")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
        }
    }
    
    private var registerButton: some View {
        Button(action: viewModel.register) {
            HStack {
                Text("Complete Registration")
                    .fontWeight(.semibold)
                Image(systemName: "arrow.right")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: viewModel.canProceed ? gradientColors : [Color.gray.opacity(0.3), Color.gray.opacity(0.3)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(!viewModel.canProceed)
        .padding(.top)
    }
}

struct InputField: View {
    let title: String
    @Binding var text: String
    let icon: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .words
    var isValid: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .frame(width: 24)
                
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autocapitalization)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isValid ? Color.blue : Color.gray,
                        lineWidth: 1
                    )
            )
        }
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RegistrationView(phoneNumber: "+14155551234")
                .preferredColorScheme(.light)
            
            RegistrationView(phoneNumber: "+14155551234")
                .preferredColorScheme(.dark)
        }
    }
}
