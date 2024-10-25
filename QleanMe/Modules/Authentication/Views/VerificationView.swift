import SwiftUI
import Combine

struct VerificationView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel: VerificationViewModel
    @FocusState private var focusedField: Int?

    let phoneNumber: String
    
    init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
        _viewModel = StateObject(wrappedValue: VerificationViewModel(phoneNumber: phoneNumber))
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView {
                VStack(spacing: 30) {
                    headerView
                    codeInputSection
                    errorMessageView
                    verifyButton
                    resendCodeButton
                }
                .padding(.horizontal, 30)
                .padding(.top, 60)
            }
            
            backButton
                .zIndex(1)
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.focusedField = 0
            }
        }
        .fullScreenCover(item: $viewModel.navigationType) { navigationType in
            switch navigationType {
            case .registeredUserDashboard:
                RegisteredUserDashboardView()
            case .contractorDashboard:
                ContractorDashboardView()
            case .registration:
                RegistrationView(phoneNumber: phoneNumber)
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
    
    private var backButton: some View {
        VStack {
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                .padding(.top, 16)
                .padding(.leading, 16)
                Spacer()
            }
            Spacer()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 10) {
            Text("Verification")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("Enter the 6-digit code sent to \(phoneNumber)")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(colorScheme == .light ? 0.9 : 0.7))
                .multilineTextAlignment(.center)
        }
    }
    
    private var codeInputSection: some View {
        HStack(spacing: 10) {
            ForEach(0..<6, id: \.self) { index in
                codeTextField(for: index)
            }
        }
    }
    
    private func codeTextField(for index: Int) -> some View {
        TextField("", text: viewModel.bindingForDigit(at: index))
            .keyboardType(.numberPad)
            .frame(width: 45, height: 60)
            .multilineTextAlignment(.center)
            .background(Color.white.opacity(0.2))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(viewModel.isCodeIncorrect ? Color.red : Color.white.opacity(0.5), lineWidth: 1)
            )
            .foregroundColor(.white)
            .font(.system(size: 24, weight: .bold))
            .focused($focusedField, equals: index)
            .onChange(of: viewModel.code[index]) { oldValue, newValue in
                if newValue.count == 1 {
                    if index < 5 {
                        focusedField = index + 1
                    } else {
                        focusedField = nil // Remove focus from the last field
                    }
                } else if newValue.isEmpty && oldValue.count == 1 {
                    focusedField = index - 1
                }
            }
    }
    
    private var errorMessageView: some View {
        Text("The code you entered is incorrect")
            .foregroundColor(.red)
            .font(.system(size: 14, weight: .medium))
            .opacity(viewModel.isCodeIncorrect ? 1 : 0)
            .animation(.easeInOut(duration: 0.3), value: viewModel.isCodeIncorrect)
    }
    
    private var verifyButton: some View {
        Button(action: viewModel.verifyCode) {
            Text("Verify")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    viewModel.isValidCode
                        ? Color.white
                        : Color.gray.opacity(0.3)
                )
                .foregroundColor(
                    viewModel.isValidCode
                        ? .blue
                        : .white.opacity(0.5)
                )
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .disabled(!viewModel.isValidCode || viewModel.isLoading)
    }
    
    private var resendCodeButton: some View {
        Button(action: viewModel.resendCode) {
            Text("Resend Code")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
        }
        .disabled(viewModel.isLoading)
    }
}

struct ContractorDashboardView: View {
    var body: some View {
        Text("Contractor Dashboard")
    }
}

struct VerificationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VerificationView(phoneNumber: "(123) 456-7890")
                .preferredColorScheme(.light)
            
            VerificationView(phoneNumber: "(123) 456-7890")
                .preferredColorScheme(.dark)
        }
    }
}

