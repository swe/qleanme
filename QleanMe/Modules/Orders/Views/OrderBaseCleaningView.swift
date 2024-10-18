import SwiftUI

struct OrderBaseCleaningView: View {
    @StateObject private var viewModel = OrderBaseCleaningViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 10), count: 3)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                roomCountSection
                areaSizeSection
                additionalServicesSection
                recurringServiceSection
                cleaningProductsSection
                specialInstructionsSection
                pricingSummary
                
                nextButton
            }
            .padding()
        }
        .navigationBarTitle("Order Cleaning", displayMode: .inline)
        .navigationBarItems(trailing: cancelButton)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private var roomCountSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What type of cleaning are you interested in?")
                .font(.headline)
            
            RoomCountRow(title: "Bedrooms", count: $viewModel.numberOfBedrooms, increment: viewModel.incrementBedrooms, decrement: viewModel.decrementBedrooms)
            
            RoomCountRow(title: "Bathrooms", count: $viewModel.numberOfBathrooms, increment: viewModel.incrementBathrooms, decrement: viewModel.decrementBathrooms)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var areaSizeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What size is the area that needs cleaning?")
                .font(.headline)
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(CleaningAreaSize.allCases) { size in
                    AreaSizeTile(size: size, isSelected: viewModel.selectedAreaSize == size) {
                        viewModel.selectedAreaSize = size
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var additionalServicesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What else needs attention?")
                .font(.headline)
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(AdditionalCleaningService.allCases) { service in
                    AdditionalServiceTile(service: service, isSelected: viewModel.selectedAdditionalServices.contains(service)) {
                        viewModel.toggleAdditionalService(service)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var recurringServiceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How often do you need this service?")
                .font(.headline)
            
            ForEach(RecurringServiceOption.allCases) { option in
                RecurringServiceButton(option: option, isSelected: viewModel.selectedRecurringOption == option) {
                    viewModel.selectedRecurringOption = option
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var cleaningProductsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cleaning Products")
                .font(.headline)
            
            CleaningProductsButton(isSelected: viewModel.bringCleaningProducts) {
                viewModel.toggleBringCleaningProducts()
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
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
    }
    
    private var pricingSummary: some View {
        HStack {
            Text("Total Price:")
                .font(.headline)
            Spacer()
            Text("$\(viewModel.totalPrice, specifier: "%.2f")")
                .font(.title2)
                .fontWeight(.bold)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var nextButton: some View {
        Button(action: {
            viewModel.printOrderDetails()
            // Add navigation to next screen or order confirmation
        }) {
            Text("Next")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
}

struct RoomCountRow: View {
    let title: String
    @Binding var count: Int
    let increment: () -> Void
    let decrement: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer()
            HStack(spacing: 15) {
                Button(action: decrement) {
                    Image(systemName: "minus")
                        .frame(width: 30, height: 30)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .clipShape(Circle())
                }
                Text("\(count)")
                    .font(.headline)
                    .frame(minWidth: 30)
                Button(action: increment) {
                    Image(systemName: "plus")
                        .frame(width: 30, height: 30)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .clipShape(Circle())
                }
            }
        }
    }
}

struct AreaSizeTile: View {
    let size: CleaningAreaSize
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: size.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .blue)
                Text(size.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .primary)
                Text(size.description)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    } else {
                        Color(UIColor.tertiarySystemGroupedBackground)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isSelected ? 0 : 0
                    )
            )
            .cornerRadius(12)
        }
    }
}

struct AdditionalServiceTile: View {
    let service: AdditionalCleaningService
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: isSelected ? service.icon.filled : service.icon.regular)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .blue)
                Text(service.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                Text("$\(service.price, specifier: "%.2f")")
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    } else {
                        Color(UIColor.tertiarySystemGroupedBackground)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isSelected ? 0 : 0
                    )
            )
            .cornerRadius(12)
        }
    }
}

struct RecurringServiceButton: View {
    let option: RecurringServiceOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(option.rawValue)
                    .foregroundColor(.primary)
                Spacer()
                if isSelected {
                    GradientCheckmark()
                }
            }
            .padding()
            .background(Color(UIColor.tertiarySystemGroupedBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: isSelected ? 2 : 0
                    )
            )
            .cornerRadius(8)
        }
    }
}

struct CleaningProductsButton: View {
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text("Bring cleaning products")
                    .foregroundColor(.primary)
                Spacer()
                if isSelected {
                    GradientCheckmark()
                }
            }
            .padding()
            .background(Color(UIColor.tertiarySystemGroupedBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: isSelected ? 2 : 0
                    )
            )
            .cornerRadius(8)
        }
    }
}

struct GradientCheckmark: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [.blue, .purple]),
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
            .mask(
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
            )
            .frame(width: 20, height: 20)
    }
}

struct OrderBaseCleaningView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OrderBaseCleaningView()
        }
    }
}
