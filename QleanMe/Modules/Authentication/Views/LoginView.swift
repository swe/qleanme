import SwiftUI

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = LoginViewModel()
    @FocusState private var isPhoneFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: 30) {
                        headerView
                        phoneInputSection
                        nextButton
                        errorMessageView
                        termsAndConditions
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 60)
                }
                
                closeButton
                
                if viewModel.isLoading {
                    LoadingView()
                }
            }
            .edgesIgnoringSafeArea(.all)
            .navigationDestination(isPresented: $viewModel.showVerificationView) {
                VerificationView(phoneNumber: viewModel.formattedPhoneNumber)
            }
            .alert(item: Binding<AlertItem?>(
                get: { viewModel.errorMessage.map { AlertItem(message: $0) } },
                set: { _ in viewModel.errorMessage = nil }
            )) { alertItem in
                Alert(title: Text("Error"), message: Text(alertItem.message), dismissButton: .default(Text("OK")))
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isPhoneFieldFocused = true
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(gradient: Gradient(colors: [
            Color(hex: colorScheme == .light ? 0x1E90FF : 0x1A1A2E),
            Color(hex: colorScheme == .light ? 0x4B0082 : 0x16213E)
        ]), startPoint: .topLeading, endPoint: .bottomTrailing)
        .edgesIgnoringSafeArea(.all)
    }
    
    private var closeButton: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                .padding(.top, 16)
                .padding(.trailing, 16)
            }
            Spacer()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 10) {
            Text("Phone Authentication")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("Enter your Canadian phone number")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(colorScheme == .light ? 0.9 : 0.7))
        }
    }
    
    private var phoneInputSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Phone Number")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(colorScheme == .light ? 0.9 : 0.7))
            
            HStack {
                Text("+1")
                    .foregroundColor(.white)
                    .padding(.leading, 16)
                
                TextField("(XXX) XXX-XXXX", text: $viewModel.phoneNumber)
                    .keyboardType(.numberPad)
                    .textContentType(.telephoneNumber)
                    .foregroundColor(.white)
                    .accentColor(.white)
                    .focused($isPhoneFieldFocused)
                    .onChange(of: viewModel.phoneNumber) { _, _ in
                        viewModel.formatPhoneNumber()
                    }
                    .padding(.vertical, 16)
            }
            .background(Color.white.opacity(colorScheme == .light ? 0.3 : 0.15))
            .cornerRadius(12)
        }
    }
    
    private var nextButton: some View {
        Button(action: viewModel.validateAndProceed) {
            HStack {
                Text("Next")
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                viewModel.isValidPhoneNumber
                    ? (colorScheme == .light ? Color.white : Color(hex: 0x4169E1))
                    : Color.gray.opacity(colorScheme == .light ? 0.3 : 0.2)
            )
            .foregroundColor(
                viewModel.isValidPhoneNumber
                    ? (colorScheme == .light ? .blue : .white)
                    : .white.opacity(colorScheme == .light ? 0.5 : 0.3)
            )
            .cornerRadius(12)
            .shadow(color: .black.opacity(colorScheme == .light ? 0.1 : 0.2), radius: 10, x: 0, y: 5)
        }
        .disabled(!viewModel.isValidPhoneNumber)
    }
    
    private var errorMessageView: some View {
        Group {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.system(size: 14))
                    .padding(.top, 8)
            }
        }
    }
    
    private var termsAndConditions: some View {
        VStack(spacing: 4) {
            Text("By continuing, you agree to our")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(colorScheme == .light ? 0.9 : 0.6))
            
            HStack(spacing: 4) {
                Link("Terms of Service", destination: URL(string: "https://qlean.me/terms")!)
                    .foregroundColor(.white.opacity(colorScheme == .light ? 0.9 : 0.6))
                Text("and")
                    .foregroundColor(.white.opacity(colorScheme == .light ? 0.9 : 0.6))
                Link("Privacy Policy", destination: URL(string: "https://qlean.me/privacy")!)
                    .foregroundColor(.white.opacity(colorScheme == .light ? 0.9 : 0.6))
            }
            .font(.system(size: 12))
            .foregroundColor(.blue)
        }
        .multilineTextAlignment(.center)
    }
}

struct AlertItem: Identifiable {
    let id = UUID()
    let message: String
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView()
                .preferredColorScheme(.light)
            
            LoginView()
                .preferredColorScheme(.dark)
        }
    }
}
