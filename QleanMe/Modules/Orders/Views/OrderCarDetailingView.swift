import SwiftUI

struct OrderCarDetailingView: View {
    @ObservedObject var viewModel: OrderCarDetailingViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                carSizeSection
                cleaningTypeSection
                additionalServicesSection
                dateTimeSection
                specialInstructionsSection
                pricingSummary
                
                nextButton
            }
            .padding()
        }
        .navigationBarTitle("Car Detailing", displayMode: .inline)
        .navigationBarItems(trailing: cancelButton)
        .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private var carSizeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Car Size")
                .font(.headline)
            
            HStack {
                ForEach(CarSize.allCases) { size in
                    CarSizeButton(size: size, isSelected: viewModel.carSize == size) {
                        viewModel.carSize = size
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var cleaningTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cleaning Type")
                .font(.headline)
            
            VStack(spacing: 8) {
                ToggleButton(isOn: $viewModel.interiorCleaning, label: "Interior Cleaning", icon: "carseat.right", filledIcon: "carseat.right.fill")
                ToggleButton(isOn: $viewModel.exteriorCleaning, label: "Exterior Cleaning", icon: "car.side", filledIcon: "car.side.fill")
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var additionalServicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Additional Services")
                .font(.headline)
            
            VStack(spacing: 8) {
                ForEach(AdditionalService.allCases) { service in
                    ToggleButton(
                        isOn: Binding(
                            get: { viewModel.additionalServices.contains(service) },
                            set: { _ in viewModel.toggleAdditionalService(service) }
                        ),
                        label: service.rawValue,
                        icon: service.icon,
                        filledIcon: service.filledIcon,
                        price: service.price
                    )
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var dateTimeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Date and Time")
                .font(.headline)
            
            HStack {
                DatePicker("", selection: $viewModel.selectedDate, in: Date()..., displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(CompactDatePickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.tertiarySystemGroupedBackground))
                    .cornerRadius(8)
                
                DatePicker("", selection: $viewModel.selectedTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(CompactDatePickerStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.tertiarySystemGroupedBackground))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var specialInstructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Special Instructions")
                .font(.headline)
            
            TextEditor(text: $viewModel.specialInstructions)
                .frame(height: 100)
                .padding(8)
                .background(Color(UIColor.tertiarySystemGroupedBackground))
                .cornerRadius(8)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var pricingSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Price Summary")
                .font(.headline)
            
            VStack(spacing: 8) {
                PriceRow(label: "Base Price", price: viewModel.basePrice)
                PriceRow(label: "Additional Services", price: viewModel.additionalServicesPrice)
                Divider()
                PriceRow(label: "Total", price: viewModel.totalPrice)
                    .font(.headline)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var nextButton: some View {
        Button(action: {
            viewModel.printCollectedData()
            // Add any additional actions here, such as navigation to the next screen
        }) {
            Text("Next")
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    viewModel.isNextButtonActive ?
                        AnyView(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing)) :
                        AnyView(Color.gray)
                )
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(!viewModel.isNextButtonActive)
    }
}

struct CarSizeButton: View {
    let size: CarSize
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: isSelected ? size.filledIcon : size.icon)
                    .font(.system(size: 24))
                Text(size.rawValue)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                isSelected ?
                    AnyView(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)) :
                    AnyView(Color(UIColor.tertiarySystemGroupedBackground))
            )
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(8)
        }
    }
}

struct ToggleButton: View {
    @Binding var isOn: Bool
    let label: String
    let icon: String
    let filledIcon: String
    let price: Double?
    
    init(isOn: Binding<Bool>, label: String, icon: String, filledIcon: String, price: Double? = nil) {
        self._isOn = isOn
        self.label = label
        self.icon = icon
        self.filledIcon = filledIcon
        self.price = price
    }
    
    var body: some View {
        Button(action: { isOn.toggle() }) {
            HStack {
                Image(systemName: isOn ? filledIcon : icon)
                Text(label)
                Spacer()
                if let price = price {
                    Text("+$\(price, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(isOn ? .white.opacity(0.8) : .secondary)
                }
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
            }
            .padding()
            .background(
                isOn ?
                    AnyView(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]), startPoint: .leading, endPoint: .trailing)) :
                    AnyView(Color(UIColor.tertiarySystemGroupedBackground))
            )
            .foregroundColor(isOn ? .white : .primary)
            .cornerRadius(8)
        }
    }
}

struct PriceRow: View {
    let label: String
    let price: Double
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text("$\(price, specifier: "%.2f")")
        }
    }
}

struct OrderCarDetailingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OrderCarDetailingView(viewModel: OrderCarDetailingViewModel())
        }
        .preferredColorScheme(.light)
        
        NavigationView {
            OrderCarDetailingView(viewModel: OrderCarDetailingViewModel())
        }
        .preferredColorScheme(.dark)
    }
}
