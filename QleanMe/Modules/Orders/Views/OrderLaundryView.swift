import SwiftUI

struct OrderLaundryView: View {
    @StateObject private var viewModel = OrderLaundryViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    private let laundryGradientColors = [Color(hex: 0x4776E6), Color(hex: 0x8E54E9)]
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    laundryServiceSelector
                    
                    if viewModel.selectedService == .dryCleaning {
                        laundryDryCleaningInfo
                        laundryClothesAmountSelector
                    } else {
                        laundryLoadSizeSelector
                    }
                    
                    if viewModel.selectedService == .washing {
                        laundryAdditionalServices
                    }
                    
                    laundrySpecialInstructions
                    laundryLocationSection
                    laundryPriceSummary
                    laundryDateTimeSection
                    
                    Color.clear.frame(height: 100)
                }
                .padding()
            }
            .onTapGesture {
                hideKeyboard()
            }
            
            VStack {
                Spacer()
                laundryBottomBar
            }
            
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $viewModel.navigateToLocation) {
            EmptyView()
        }
        .sheet(isPresented: $viewModel.showLocationPicker) {
            OrderLaundryLocationView(viewModel: viewModel)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), actions: {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        }, message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        })
    }
    
    private var laundryServiceSelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Service Type")
                .font(.headline)
            
            HStack(spacing: 12) {
                ForEach(LaundryServiceType.allCases) { service in
                    LaundryServiceOptionButton(
                        service: service,
                        isSelected: viewModel.selectedService == service,
                        gradientColors: laundryGradientColors,
                        price: service.basePrice
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.selectService(service)
                        }
                    }
                }
            }
        }
    }
    
    private var laundryDryCleaningInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Important Information")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(laundryGradientColors[0])
            
            Text("Dry cleaning service typically takes 3-5 days to complete. We'll make sure your clothes are properly cleaned and carefully handled.")
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(UIColor.separator), lineWidth: 0.5)
                )
        )
    }
    
    private var laundryLoadSizeSelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Load Size")
                .font(.headline)
            
            HStack(spacing: 12) {
                ForEach(LaundryLoadSize.allCases) { size in
                    LaundryLoadSizeButton(
                        size: size,
                        isSelected: viewModel.selectedLoadSize == size,
                        gradientColors: laundryGradientColors
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.selectLoadSize(size)
                        }
                    }
                }
            }
        }
    }
    
    private var laundryClothesAmountSelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Number of Items")
                .font(.headline)
            
            HStack(spacing: 20) {
                Button(action: viewModel.decrementClothes) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(viewModel.clothesAmount > 1 ? laundryGradientColors[0] : .gray)
                }
                
                Text("\(viewModel.clothesAmount)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(minWidth: 40)
                
                Button(action: viewModel.incrementClothes) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(laundryGradientColors[0])
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
    
    private var laundryAdditionalServices: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Additional Services")
                .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(LaundryAddonType.allCases) { addon in
                    LaundryAddonOptionButton(
                        addon: addon,
                        isSelected: viewModel.selectedAddons.contains(addon),
                        gradientColors: laundryGradientColors
                    ) {
                        viewModel.toggleAddon(addon)
                    }
                }
            }
        }
    }
    
    private var laundrySpecialInstructions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Special Instructions")
                .font(.headline)
            
            TextEditor(text: $viewModel.specialInstructions)
                .frame(height: 100)
                .padding(8)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(UIColor.separator), lineWidth: 0.5)
                )
                .overlay(
                    Text("Add any special instructions or notes here...")
                        .foregroundColor(.secondary)
                        .padding(16)
                        .opacity(viewModel.specialInstructions.isEmpty ? 1 : 0),
                    alignment: .topLeading
                )
        }
    }
    
    private var laundryLocationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pickup Location")
                .font(.headline)
            
            Button(action: {
                viewModel.showLocationPicker = true
            }) {
                HStack {
                    if let address = viewModel.selectedAddress {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: address.type.iconName)
                                    .foregroundColor(laundryGradientColors[0])
                                Text(address.title)
                                    .fontWeight(.medium)
                                if address.isDefault {
                                    Text("Default")
                                        .font(.caption)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(laundryGradientColors[0].opacity(0.2))
                                        .foregroundColor(laundryGradientColors[0])
                                        .cornerRadius(4)
                                }
                            }
                            Text(address.fullAddress)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                            
                            Text("Tap to change")
                                .font(.caption)
                                .foregroundColor(laundryGradientColors[0])
                        }
                    } else {
                        HStack {
                            Image(systemName: "location.circle.fill")
                                .foregroundColor(laundryGradientColors[0])
                            Text("Select pickup address")
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
    }
    
    private var laundryPriceSummary: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Price Summary")
                .font(.headline)
            
            VStack(spacing: 12) {
                LaundryPriceSummaryRow(
                    title: viewModel.selectedService.rawValue,
                    value: viewModel.basePrice
                )
                
                if !viewModel.selectedAddons.isEmpty {
                    ForEach(Array(viewModel.selectedAddons)) { addon in
                        LaundryPriceSummaryRow(
                            title: addon.name,
                            value: addon.price
                        )
                    }
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                LaundryPriceSummaryRow(
                    title: "Total",
                    value: viewModel.totalPrice,
                    isTotal: true
                )
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
    
    private var laundryDateTimeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Date and Time")
                .font(.headline)
            
            HStack(spacing: 12) {
                Button(action: {
                    viewModel.showDatePicker = true
                }) {
                    Text(formattedDate)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                }
                .sheet(isPresented: $viewModel.showDatePicker) {
                    LaundryDatePickerSheet(
                        selectedDate: $viewModel.selectedDate,
                        isPresented: $viewModel.showDatePicker,
                        minDate: viewModel.minimumDate,
                        maxDate: viewModel.maximumDate
                    )
                }
                
                Button(action: {
                    viewModel.showTimePicker = true
                }) {
                    Text(formattedTime)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(width: 100)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                }
                .sheet(isPresented: $viewModel.showTimePicker) {
                    LaundryTimePickerSheet(
                        selectedTime: $viewModel.selectedTime,
                        isPresented: $viewModel.showTimePicker
                    )
                }
            }
        }
    }
    
    private var laundryBottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("$\(NSDecimalNumber(decimal: viewModel.totalPrice).doubleValue, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Button(action: {
                    viewModel.proceedToLocation()
                }) {
                    HStack {
                        Text("Next")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: viewModel.canProceed ? laundryGradientColors : [Color.gray.opacity(0.3)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!viewModel.canProceed)
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
            .background(.ultraThinMaterial)
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: viewModel.selectedDate)
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: viewModel.selectedTime)
    }
}

struct LaundryServiceOptionButton: View {
    let service: LaundryServiceType
    let isSelected: Bool
    let gradientColors: [Color]
    let price: Decimal
    let action: () -> Void
    
    private let buttonSize: CGFloat = (UIScreen.main.bounds.width - 48) / 3
    private let circleSize: CGFloat = 60
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: gradientColors),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    } else {
                        Circle()
                            .fill(Color(UIColor.tertiarySystemFill))
                    }
                    
                    Image(systemName: service.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .white : .secondary)
                }
                .frame(width: circleSize, height: circleSize)
                
                Text(service.rawValue)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? gradientColors[0] : .secondary)
                
                Text("$\(NSDecimalNumber(decimal: price).doubleValue, specifier: "%.2f")")
                    .font(.caption)
                    .foregroundColor(isSelected ? gradientColors[0] : .secondary)
            }
            .frame(width: buttonSize)
            .padding(.vertical, 8)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: isSelected ? gradientColors : [Color.clear]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LaundryLoadSizeButton: View {
    let size: LaundryLoadSize
    let isSelected: Bool
    let gradientColors: [Color]
    let action: () -> Void
    
    private let buttonSize: CGFloat = (UIScreen.main.bounds.width - 48) / 3
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(size.rawValue)
                    .font(.headline)
                    .fontWeight(isSelected ? .semibold : .regular)
                
                Text(size.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: buttonSize)
            .padding(.vertical, 12)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: isSelected ? gradientColors : [Color.clear]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .foregroundColor(isSelected ? gradientColors[0] : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LaundryAddonOptionButton: View {
    let addon: LaundryAddonType
    let isSelected: Bool
    let gradientColors: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: addon.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                    .frame(width: 24)
                
                Text(addon.name)
                    .font(.body)
                
                Spacer()
                
                Text("+$\(NSDecimalNumber(decimal: addon.price).doubleValue, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .secondary)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: isSelected ? gradientColors : [Color.clear]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LaundryPriceSummaryRow: View {
    let title: String
    let value: Decimal
    var isTotal: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .font(isTotal ? .headline : .body)
            Spacer()
            Text("$\(NSDecimalNumber(decimal: value).doubleValue, specifier: "%.2f")")
                .font(isTotal ? .headline : .body)
                .fontWeight(isTotal ? .bold : .regular)
        }
    }
}

struct LaundryDatePickerSheet: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    let minDate: Date
    let maxDate: Date
    
    var body: some View {
        NavigationView {
            DatePicker(
                "",
                selection: $selectedDate,
                in: minDate...maxDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .padding()
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct LaundryTimePickerSheet: View {
    @Binding var selectedTime: Date
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    
    private let startHour = 8  // 8 AM
    private let endHour = 20   // 8 PM
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .padding()
                .onChange(of: selectedTime) { oldValue, newValue in
                    let hour = Calendar.current.component(.hour, from: newValue)
                    if hour < startHour || hour >= endHour {
                        selectedTime = Calendar.current.date(
                            bySettingHour: hour < startHour ? startHour : endHour-1,
                            minute: Calendar.current.component(.minute, from: newValue),
                            second: 0,
                            of: newValue
                        ) ?? newValue
                    }
                }
            }
            .navigationTitle("Select Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
        .presentationDetents([.height(300)])
    }
}

struct OrderLaundryLocationView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: OrderLaundryViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isLoading {
                        ProgressView("Loading addresses...")
                            .padding()
                    } else {
                        savedAddressesSection
                        addNewAddressButton
                    }
                }
                .padding()
            }
            .navigationTitle("Select Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var savedAddressesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Saved Addresses")
                .font(.headline)
            
            ForEach(viewModel.savedAddresses) { address in
                OrderAddressCard(address: address, isSelected: viewModel.selectedAddress?.id == address.id) {
                    viewModel.setAddress(address)
                }
            }
        }
    }
    
    private var addNewAddressButton: some View {
        Button(action: {
            // TODO: Implement add new address functionality
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add New Address")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(12)
        }
    }
}

struct OrderAddressCard: View {
    let address: LaundryAddress
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top) {
                Image(systemName: address.type.iconName)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(address.title)
                            .font(.headline)
                        if address.isDefault {
                            Text("Default")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(address.fullAddress)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .secondary)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OrderLaundryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OrderLaundryView()
                .preferredColorScheme(.light)
            
            OrderLaundryView()
                .preferredColorScheme(.dark)
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
