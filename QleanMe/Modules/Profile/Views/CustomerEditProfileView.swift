import SwiftUI

struct CustomerEditProfileView: View {
    @StateObject private var viewModel = CustomerEditProfileViewModel()
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) private var colorScheme
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                profileImageSection
                personalInfoSection
                addressesSection
                paymentMethodsSection
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .overlay(
            Group {
                if viewModel.isLoading {
                    ProgressView("Updating profile...")
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            }
        )
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
        .alert(item: Binding<AlertItem?>(
            get: { viewModel.errorMessage.map { AlertItem(message: $0) } },
            set: { _ in viewModel.errorMessage = nil }
        )) { alertItem in
            Alert(title: Text("Error"), message: Text(alertItem.message), dismissButton: .default(Text("OK")))
        }
    }
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
        }
    }
    
    private var profileImageSection: some View {
        VStack {
            if let image = viewModel.profileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
            }
            
            Button(action: {
                viewModel.showImagePicker = true
            }) {
                Text("Change Profile Picture")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding(.top, 8)
        }
    }
    
    private var personalInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal Information")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 16) {
                CustomTextField(icon: "person.fill", placeholder: "Full Name", text: $viewModel.fullName)
                CustomTextField(icon: "envelope.fill", placeholder: "Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                CustomTextField(icon: "phone.fill", placeholder: "Phone Number", text: Binding(
                    get: { viewModel.phoneNumber },
                    set: { viewModel.phoneNumber = viewModel.formatPhoneNumber($0) }
                ))
                .keyboardType(.phonePad)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var addressesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Addresses")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button(action: {
                    viewModel.showAddressForm = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
                .disabled(viewModel.addresses.count >= 10)
            }
            
            ForEach(viewModel.addresses) { address in
                AddressRow(address: address)
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
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var paymentMethodsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Payment Methods")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Button(action: {
                    viewModel.showPaymentMethodForm = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            
            ForEach(viewModel.paymentMethods) { paymentMethod in
                PaymentMethodRow(paymentMethod: paymentMethod)
                    .swipeActions {
                        Button(role: .destructive) {
                            if let index = viewModel.paymentMethods.firstIndex(where: { $0.id == paymentMethod.id }) {
                                viewModel.removePaymentMethod(at: index)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)
            TextField(placeholder, text: $text)
        }
        .padding()
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .cornerRadius(8)
    }
}

struct AddressRow: View {
    let address: Address
    
    var body: some View {
        HStack {
            Image(systemName: "mappin.circle.fill")
                .foregroundColor(.blue)
            VStack(alignment: .leading) {
                Text(address.street)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Text("\(address.city), \(address.province) \(address.postalCode)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}


struct PaymentMethodRow: View {
    let paymentMethod: PaymentMethod
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            if paymentMethod.type == .applePay {
                Image(systemName: "applelogo")
                    .foregroundColor(colorScheme == .light ? .black : .white)
            } else {
                Image(systemName: "creditcard.fill")
                    .foregroundColor(.blue)
            }
            
            Text(paymentMethod.type == .applePay ? "Apple Pay" : "Credit Card")
                .font(.subheadline)
                .foregroundColor(.primary)
            
            if let last4 = paymentMethod.last4 {
                Spacer()
                Text("•••• \(last4)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else if paymentMethod.type == .applePay {
                Spacer()
                Text("Connected")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
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
