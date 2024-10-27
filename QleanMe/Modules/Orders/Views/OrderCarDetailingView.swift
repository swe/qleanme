import SwiftUI

struct OrderCarDetailingView: View {
    @StateObject private var viewModel = OrderCarDetailingViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    private let carDetailingGradientColors = [Color(hex: 0x4776E6), Color(hex: 0x8E54E9)]
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    carTypeSelector
                    cleaningTypeSelector
                    cleaningDepthSelector
                    additionalServicesSection
                    specialInstructionsSection
                    priceSummarySection
                    dateTimeSection
                    
                    Color.clear.frame(height: 100)
                }
                .padding()
            }
            .onTapGesture {
                hideKeyboard()
            }
            
            VStack {
                Spacer()
                bottomBar
            }
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .navigationDestination(isPresented: $viewModel.navigateToLocation) {
            EmptyView()
        }
        .sheet(isPresented: $viewModel.showDatePicker) {
            LaundryDatePickerSheet(
                selectedDate: $viewModel.selectedDate,
                isPresented: $viewModel.showDatePicker,
                minDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                maxDate: Calendar.current.date(byAdding: .month, value: 2, to: Date()) ?? Date()
            )
        }
        .sheet(isPresented: $viewModel.showTimePicker) {
            LaundryTimePickerSheet(
                selectedTime: $viewModel.selectedTime,
                isPresented: $viewModel.showTimePicker
            )
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
    
    private var carTypeSelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Vehicle Type")
                .font(.headline)
            
            HStack(spacing: 12) {
                ForEach(CarType.allCases) { carType in
                    CarTypeOptionButton(
                        carType: carType,
                        isSelected: viewModel.selectedCarType == carType,
                        gradientColors: carDetailingGradientColors
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.selectedCarType = carType
                        }
                    }
                }
            }
        }
    }
    
    private var cleaningTypeSelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Service Type")
                .font(.headline)
            
            HStack(spacing: 12) {
                ForEach(CleaningType.allCases) { cleaningType in
                    CleaningTypeOptionButton(
                        cleaningType: cleaningType,
                        isSelected: viewModel.selectedCleaningType == cleaningType,
                        gradientColors: carDetailingGradientColors
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.selectedCleaningType = cleaningType
                        }
                    }
                }
            }
        }
    }
    
    private var cleaningDepthSelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Service Level")
                .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(CleaningDepth.allCases) { depth in
                    CleaningDepthOptionButton(
                        depth: depth,
                        isSelected: viewModel.selectedDepth == depth,
                        gradientColors: carDetailingGradientColors
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.selectedDepth = depth
                        }
                    }
                }
            }
        }
    }
    
    private var additionalServicesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Additional Services")
                .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(CarDetailingAddon.allAddons) { addon in
                    AddonOptionButton(
                        addon: addon,
                        isSelected: viewModel.selectedAddons.contains(addon),
                        gradientColors: carDetailingGradientColors
                    ) {
                        viewModel.toggleAddon(addon)
                    }
                }
            }
        }
    }
    
    private var specialInstructionsSection: some View {
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
                    Text("Add any special requests or notes here...")
                        .foregroundColor(.secondary)
                        .padding(16)
                        .opacity(viewModel.specialInstructions.isEmpty ? 1 : 0),
                    alignment: .topLeading
                )
        }
    }
    
    private var priceSummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Price Summary")
                .font(.headline)
            
            VStack(spacing: 12) {
                PriceSummaryRow(
                    title: "\(viewModel.selectedDepth.rawValue) Detailing",
                    value: viewModel.basePrice
                )
                
                ForEach(Array(viewModel.selectedAddons)) { addon in
                    PriceSummaryRow(
                        title: addon.name,
                        value: addon.price
                    )
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                PriceSummaryRow(
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
    
    private var dateTimeSection: some View {
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
            }
        }
    }
    
    private var bottomBar: some View {
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
                            if viewModel.isSubmitting {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Next")
                                    .fontWeight(.semibold)
                                Image(systemName: "arrow.right")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: viewModel.canProceed ? carDetailingGradientColors : [Color.gray.opacity(0.3)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!viewModel.canProceed || viewModel.isSubmitting)
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

// Supporting Views
struct CarTypeOptionButton: View {
    let carType: CarType
    let isSelected: Bool
    let gradientColors: [Color]
    let action: () -> Void
    
    private let buttonSize: CGFloat = (UIScreen.main.bounds.width - 60) / 4
    private let circleSize: CGFloat = 50
    
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
                    
                    Image(systemName: carType.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .white : .secondary)
                }
                .frame(width: circleSize, height: circleSize)
                
                Text(carType.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? gradientColors[0] : .secondary)
            }
            .frame(width: buttonSize)
            .padding(.vertical, 8)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
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

struct CleaningTypeOptionButton: View {
    let cleaningType: CleaningType
    let isSelected: Bool
    let gradientColors: [Color]
    let action: () -> Void
    
    private let buttonSize: CGFloat = (UIScreen.main.bounds.width - 48) / 3
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: cleaningType.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? gradientColors[0] : .secondary)
                
                Text(cleaningType.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                
                Text(cleaningType.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: buttonSize)
            .padding(.vertical, 12)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
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

struct CleaningDepthOptionButton: View {
    let depth: CleaningDepth
    let isSelected: Bool
    let gradientColors: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(depth.rawValue)
                            .font(.headline)
                            .foregroundColor(isSelected ? gradientColors[0] : .primary)
                        
                        Text(depth.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("$\(NSDecimalNumber(decimal: depth.price).doubleValue, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(isSelected ? gradientColors[0] : .primary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(depth.features, id: \.self) { feature in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(isSelected ? gradientColors[0] : .secondary)
                                .font(.system(size: 14))
                            
                            Text(feature)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
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

struct AddonOptionButton: View {
    let addon: CarDetailingAddon
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
                    .foregroundColor(isSelected ? gradientColors[0] : .secondary)
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

struct PriceSummaryRow: View {
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

struct OrderCarDetailingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OrderCarDetailingView()
                .preferredColorScheme(.light)
        }
        
        NavigationView {
            OrderCarDetailingView()
                .preferredColorScheme(.dark)
        }
    }
}
