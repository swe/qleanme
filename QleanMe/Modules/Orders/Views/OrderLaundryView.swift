import SwiftUI

struct OrderLaundryView: View {
    @ObservedObject var viewModel: OrderLaundryViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                serviceTypeSection
                loadSizeSection
                if viewModel.serviceType.allowsAdditionalServices {
                    additionalServicesSection
                }
                dateTimeSection
                specialInstructionsSection
                pricingSummary
                
                nextButton
            }
            .padding()
        }
        .navigationBarTitle("Laundry Service", displayMode: .inline)
        .navigationBarItems(trailing: cancelButton)
        .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private var serviceTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Service Type")
                .font(.headline)
            
            HStack {
                ForEach(LaundryServiceType.allCases) { type in
                    ServiceTypeButton(type: type, isSelected: viewModel.serviceType == type) {
                        viewModel.serviceType = type
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
    
    private var loadSizeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Load Size")
                .font(.headline)
            
            HStack {
                ForEach(LoadSize.allCases) { size in
                    LoadSizeButton(size: size, isSelected: viewModel.loadSize == size) {
                        viewModel.loadSize = size
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
    
    private var additionalServicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Additional Services")
                .font(.headline)
            
            VStack(spacing: 8) {
                ForEach(AdditionalLaundryService.allCases) { service in
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
            
            DatePicker(
                "Select Date and Time",
                selection: Binding(
                    get: {
                        Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: viewModel.selectedTime),
                                              minute: Calendar.current.component(.minute, from: viewModel.selectedTime),
                                              second: 0,
                                              of: viewModel.selectedDate) ?? Date()
                    },
                    set: { newValue in
                        viewModel.selectedDate = Calendar.current.startOfDay(for: newValue)
                        viewModel.selectedTime = newValue
                    }
                ),
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .labelsHidden()
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
            
            if let dryCleanNote = viewModel.serviceType.dryCleanNote {
                Text(dryCleanNote)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
            }
            
            VStack(spacing: 8) {
                PriceRow(label: "Base Price", price: viewModel.basePrice)
                if viewModel.serviceType.allowsAdditionalServices {
                    PriceRow(label: "Additional Services", price: viewModel.additionalServicesPrice)
                }
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

struct ServiceTypeButton: View {
    let type: LaundryServiceType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: isSelected ? type.filledIcon : type.icon)
                    .font(.system(size: 24))
                Text(type.rawValue)
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

struct LoadSizeButton: View {
    let size: LoadSize
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: size.icon)
                    .font(.system(size: 24))
                Text(size.name)
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

struct OrderLaundryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OrderLaundryView(viewModel: OrderLaundryViewModel())
        }
        .preferredColorScheme(.light)
        
        NavigationView {
            OrderLaundryView(viewModel: OrderLaundryViewModel())
        }
        .preferredColorScheme(.dark)
    }
}
