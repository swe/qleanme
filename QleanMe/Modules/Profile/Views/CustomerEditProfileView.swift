import SwiftUI

struct CustomerEditProfileView: View {
    @StateObject private var viewModel = CustomerEditProfileViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.hideTabBar) private var hideTabBar
    
    private let gradientColors = [Color(hex: 0x4776E6), Color(hex: 0x8E54E9)]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    gradientColors[0].opacity(0.1),
                    gradientColors[1].opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    profileImageSection
                    personalInfoSection
                    addressesSection
                    // paymentMethodsSection
                    
                    if !viewModel.validationErrors.isEmpty {
                        validationErrorsView
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Edit Profile")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                    }
                    .foregroundColor(gradientColors[0])
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.saveProfile() }) {
                    Text("Save")
                        .fontWeight(.semibold)
                        .foregroundColor(viewModel.canSave ? gradientColors[0] : .gray)
                }
                .disabled(!viewModel.canSave)
            }
        }
        .overlay {
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePicker(image: $viewModel.profileImage)
        }
        .sheet(isPresented: $viewModel.showAddressForm) {
            AddressFormView { address in
                viewModel.addAddress(address)
            }
        }
        .sheet(isPresented: $viewModel.showPaymentMethodForm) {
            PaymentMethodFormView { paymentMethod in
                viewModel.addPaymentMethod(paymentMethod)
            }
        }
        .alert("Success", isPresented: $viewModel.showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your profile has been updated successfully.")
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private var profileImageSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                gradientColors[0].opacity(0.2),
                                gradientColors[1].opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 125, height: 125)
                
                if let image = viewModel.profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 110, height: 110)
                        .foregroundColor(gradientColors[0])
                }
                
                Button(action: {
                    viewModel.showImagePicker = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(UIColor.systemBackground))
                            .frame(width: 36, height: 36)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                        Image(systemName: "camera.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(gradientColors[0])
                    }
                }
                .offset(x: 40, y: 40)
            }
        }
        .padding(.vertical, 20)
    }
    
    private var personalInfoSection: some View {
            VStack(alignment: .leading, spacing: 20) {
                SectionHeader(icon: "person.fill", title: "Personal Information", gradientColors: gradientColors)
                
                VStack(spacing: 16) {
                    CustomTextField(
                        icon: "person.fill",
                        placeholder: "Full Name",
                        text: $viewModel.fullName,
                        colors: gradientColors,
                        isValid: viewModel.isValidName
                    )
                    
                    CustomTextField(
                        icon: "envelope.fill",
                        placeholder: "Email",
                        text: $viewModel.email,
                        colors: gradientColors,
                        isValid: viewModel.isValidEmail
                    )
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    
                    // Phone number display with support note
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "phone.fill")
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: gradientColors,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 24)
                            
                            Text(viewModel.phoneNumber)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "lock.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                        }
                        .padding()
                        .background(Color(UIColor.tertiarySystemGroupedBackground))
                        .cornerRadius(12)
                        
                        HStack(alignment: .top, spacing: 4) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(gradientColors[0])
                                .font(.system(size: 14))
                            
                            Text("To change your phone number, please contact support")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 4)
                    }
                    
                    Toggle(isOn: $viewModel.notificationsEnabled) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: gradientColors,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text("Enable Notifications")
                                .foregroundColor(.primary)
                        }
                    }
                    .tint(gradientColors[0])
                }
            }
            .padding(20)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    
    private var addressesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                SectionHeader(icon: "location.fill", title: "Addresses", gradientColors: gradientColors)
                Spacer()
                Button(action: {
                    viewModel.showAddressForm = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(gradientColors[0])
                }
                .disabled(viewModel.addresses.count >= 10)
                .opacity(viewModel.addresses.count >= 10 ? 0.5 : 1)
            }
            
            if viewModel.addresses.isEmpty {
                EmptyAddressesView(colors: gradientColors) {
                    viewModel.showAddressForm = true
                }
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.addresses) { address in
                        AddressRow(address: address, colors: gradientColors)
                            .swipeActions {
                                Button(role: .destructive) {
                                    if let index = viewModel.addresses.firstIndex(where: { $0.id == address.id }) {
                                        viewModel.removeAddress(at: index)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var paymentMethodsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                SectionHeader(icon: "creditcard.fill", title: "Payment Methods", gradientColors: gradientColors)
                Spacer()
                Button(action: {
                    viewModel.showPaymentMethodForm = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(gradientColors[0])
                }
            }
            
            if viewModel.paymentMethods.isEmpty {
                EmptyPaymentMethodsView(colors: gradientColors) {
                    viewModel.showPaymentMethodForm = true
                }
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.paymentMethods) { method in
                        PaymentMethodRow(method: method, colors: gradientColors)
                            .swipeActions {
                                Button(role: .destructive) {
                                    if let index = viewModel.paymentMethods.firstIndex(where: { $0.id == method.id }) {
                                        viewModel.removePaymentMethod(at: index)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var validationErrorsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(viewModel.validationErrors, id: \.id) { error in
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                    Text(error.message)
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }
}



struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    let colors: [Color]
    let isValid: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(
                    LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 24)
            
            TextField(placeholder, text: $text)
                .font(.body)
        }
        .padding()
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        colors: !isValid ? [Color.red] : (text.isEmpty ? [Color(UIColor.separator)] : colors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: !isValid ? 2 : (text.isEmpty ? 0.5 : 1.5)
                )
        )
    }
}

struct SectionHeader: View {
    let icon: String
    let title: String
    let gradientColors: [Color]
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text(title)
                .font(.headline)
        }
    }
}

struct AddressRow: View {
    let address: Address
    let colors: [Color]
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colors.map { $0.opacity(0.2) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(address.street)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("\(address.city), \(address.province) \(address.postalCode)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct PaymentMethodRow: View {
    let method: PaymentMethod
    let colors: [Color]
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colors.map { $0.opacity(0.2) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: method.type == .applePay ? "apple.logo" : "creditcard.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(method.type == .applePay ? "Apple Pay" : "Card")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let last4 = method.last4 {
                    Text("•••• \(last4)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct EmptyPaymentMethodsView: View {
    let colors: [Color]
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colors.map { $0.opacity(0.2) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text("No payment methods")
                .font(.headline)
            
            Text("Add your first payment method")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: action) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Payment Method")
                }
                .font(.system(size: 16, weight: .semibold))
                .padding()
                .foregroundColor(.white)
                .background(
                    LinearGradient(
                        colors: colors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
        }
        .padding()
    }
}

struct EmptyAddressesView: View {
    let colors: [Color]
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colors.map { $0.opacity(0.2) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: "house.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text("No addresses yet")
                .font(.headline)
            
            Text("Add your first address to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: action) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Address")
                }
                .font(.system(size: 16, weight: .semibold))
                .padding()
                .foregroundColor(.white)
                .background(
                    LinearGradient(
                        colors: colors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
        }
        .padding()
    }
}

struct CustomerEditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CustomerEditProfileView()
        }
        .preferredColorScheme(.light)
        
        NavigationView {
            CustomerEditProfileView()
        }
        .preferredColorScheme(.dark)
    }
}
