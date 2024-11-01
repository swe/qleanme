import SwiftUI

struct TestingReviewView: View {
    var body: some View {
        VStack {
            Text("Testing Review View")
                .font(.title)
                .padding()
            Text("This is a placeholder for the review screen")
                .foregroundColor(.secondary)
        }
    }
}

struct HomeCleaningAdditionalView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel: HomeCleaningAdditionalViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showTestingReview = false
    
    init(cleaningDetails: OrderHomeCleaningViewModel) {
        self._viewModel = StateObject(wrappedValue: HomeCleaningAdditionalViewModel(cleaningDetails: cleaningDetails))
    }
    
    private let gradientColors = [Color(hex: 0x2193b0), Color(hex: 0x6dd5ed)]
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 24) {
                        petsSection
                        cleaningSuppliesSection
                        vacuumSection
                        locationSection
                        specialInstructionsSection
                        
                        Color.clear.frame(height: 100)
                    }
                    .padding()
                }
                .background(backgroundGradient)
                
                VStack {
                    Spacer()
                    bottomBar
                }
            }
            .navigationDestination(isPresented: $showTestingReview) {
                TestingReviewView()
            }
            .navigationTitle("Additional Details")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.showLocationPicker) {
                OrderCleaningLocationPickerView()
            }
            .sheet(isPresented: $viewModel.showSavedAddresses) {
                EmptyView() // This will be replaced with the saved addresses view later
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                gradientColors[0].opacity(0.1),
                gradientColors[1].opacity(0.05)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var petsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(icon: "pawprint.fill", title: "Pets", gradientColors: gradientColors)
            
            Toggle("Do you have pets?", isOn: $viewModel.hasPets)
                .tint(gradientColors[0])
            
            if viewModel.hasPets {
                TextEditor(text: $viewModel.petDetails)
                    .frame(height: 80)
                    .padding(8)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(UIColor.separator), lineWidth: 0.5)
                    )
                    .overlay(
                        Group {
                            if viewModel.petDetails.isEmpty {
                                Text("Please provide details about your pets...")
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 16)
                                    .allowsHitTesting(false)
                            }
                        },
                        alignment: .topLeading
                    )
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var cleaningSuppliesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(icon: "waterbottle.fill", title: "Cleaning Supplies", gradientColors: gradientColors)
            
            HStack(spacing: 12) {
                SupplyOptionCard(
                    title: "I have my own",
                    icon: "house.fill",
                    isSelected: viewModel.cleaningSupplies == .own,
                    gradientColors: gradientColors
                ) {
                    viewModel.cleaningSupplies = .own
                }
                
                SupplyOptionCard(
                    title: "Bring supplies",
                    icon: "bag.fill",
                    isSelected: viewModel.cleaningSupplies == .bring,
                    gradientColors: gradientColors
                ) {
                    viewModel.cleaningSupplies = .bring
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var vacuumSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(icon: "vacuum.fill", title: "Vacuum", gradientColors: gradientColors)
            
            Button(action: { viewModel.hasVacuum.toggle() }) {
                HStack {
                    GradientIcon(icon: "hand.thumbsup.fill", colors: gradientColors)
                        .frame(width: 30, height: 30)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("I have a vacuum")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Let us know if you have your own vacuum")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: viewModel.hasVacuum ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(viewModel.hasVacuum ? gradientColors[0] : .secondary)
                        .font(.title3)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                colors: viewModel.hasVacuum ? gradientColors : [Color(UIColor.separator)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: viewModel.hasVacuum ? 2 : 1
                        )
                )
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(icon: "location.fill", title: "Location", gradientColors: gradientColors)
            
            if viewModel.location.isEmpty {
                Button(action: {
                    viewModel.showAddressOptions()
                }) {
                    HStack {
                        GradientIcon(icon: "mappin.circle.fill", colors: gradientColors)
                            .frame(width: 30, height: 30)
                        
                        Text("Select your address")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                Color(UIColor.separator),
                                lineWidth: 1
                            )
                    )
                }
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 12) {
                        GradientIcon(icon: "mappin.circle.fill", colors: gradientColors)
                            .frame(width: 30, height: 30)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.location)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.showAddressOptions()
                        }) {
                            Text("Change")
                                .font(.subheadline)
                                .foregroundColor(gradientColors[0])
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            Color(UIColor.separator),
                            lineWidth: 1
                        )
                )
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .alert("How would you like to add address?", isPresented: $viewModel.showAddressAlert) {
            Button("Add using the map") {
                viewModel.handleAddressSelection(.map)
            }
            Button("Add from saved places") {
                viewModel.handleAddressSelection(.saved)
            }
            Button("Back", role: .cancel) {}
        } message: {
            Text("Please, make a decision, how would you like to add address for our services?")
        }
    }
    
    private var specialInstructionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(icon: "text.bubble.fill", title: "Special Instructions", gradientColors: gradientColors)
            
            TextEditor(text: $viewModel.specialInstructions)
                .frame(height: 100)
                .padding(8)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(UIColor.separator), lineWidth: 0.5)
                )
                .overlay(
                    Group {
                        if viewModel.specialInstructions.isEmpty {
                            Text("Add any special instructions or notes for the cleaner...")
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 16)
                                .allowsHitTesting(false)
                        }
                    },
                    alignment: .topLeading
                )
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(String(format: "$%.2f", NSDecimalNumber(decimal: viewModel.cleaningDetails.totalPrice).doubleValue))
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Button(action: {
                    if viewModel.isValid {
                        showTestingReview = true
                    }
                }) {
                    HStack {
                        Text("Review")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(!viewModel.isValid)
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
            .background(.ultraThinMaterial)
        }
    }
}

/* Supporting Views
struct SectionHeader: View {
    let icon: String
    let title: String
    let gradientColors: [Color]
    
    var body: some View {
        HStack(spacing: 8) {
            GradientIcon(icon: icon, colors: gradientColors)
                .frame(width: 24, height: 24)
            Text(title)
                .font(.headline)
        }
    }
}
*/

struct GradientIcon: View {
    let icon: String
    let colors: [Color]
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .mask(
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
        )
    }
}

struct SupplyOptionCard: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let gradientColors: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isSelected ? gradientColors : [Color(UIColor.tertiarySystemFill)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    if isSelected {
                        GradientIcon(icon: icon, colors: [.white])
                            .frame(width: 24, height: 24)
                    } else {
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? gradientColors[0] : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            colors: isSelected ? gradientColors : [Color.clear],
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

struct CleaningTypeCard: View {
    let type: HomeCleaningType
    let isSelected: Bool
    let gradientColors: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isSelected ? gradientColors : [Color(UIColor.tertiarySystemFill)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: type.iconName)
                        .font(.title2)
                        .foregroundColor(isSelected ? .white : .gray)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(type.rawValue)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(type.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Text("from $\((type.basePrice as NSDecimalNumber).doubleValue, specifier: "%.2f")")
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? gradientColors[0] : .secondary)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .shadow(color: isSelected ? gradientColors[0].opacity(0.3) : Color.black.opacity(0.1),
                    radius: isSelected ? 10 : 5,
                    x: 0,
                    y: isSelected ? 5 : 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CounterButton: View {
    let systemName: String
    let isEnabled: Bool
    let gradientColors: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 35, height: 35)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isEnabled ? gradientColors : [Color(UIColor.systemGray4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        }
        .disabled(!isEnabled)
    }
}

struct RoomCountSelector: View {
    let title: String
    var subtitle: String? = nil
    let count: Int
    let increment: () -> Void
    let decrement: () -> Void
    let gradientColors: [Color]
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                CounterButton(
                    systemName: "minus",
                    isEnabled: count > 1,
                    gradientColors: gradientColors,
                    action: decrement
                )
                
                Text("\(count)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(minWidth: 30)
                
                CounterButton(
                    systemName: "plus",
                    isEnabled: count < 10,
                    gradientColors: gradientColors,
                    action: increment
                )
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct PropertySizeCard: View {
    let size: PropertySize
    let isSelected: Bool
    let gradientColors: [Color]
    let action: () -> Void
    
    private let buttonSize: CGFloat = (UIScreen.main.bounds.width - 48 - 24) / 3
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isSelected ? gradientColors : [Color(UIColor.tertiarySystemFill)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: isSelected ? "checkmark" : "ruler")
                            .foregroundColor(isSelected ? .white : .gray)
                    }
                
                Text(size.rawValue)
                    .font(.headline)
                    .fontWeight(isSelected ? .semibold : .regular)
                
                Text(size.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(width: buttonSize)
            .padding(.vertical, 16)
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: isSelected ? gradientColors[0].opacity(0.3) : Color.black.opacity(0.1),
                    radius: isSelected ? 10 : 5,
                    x: 0,
                    y: isSelected ? 5 : 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AdditionalServiceCard: View {
    let service: AdditionalService
    let isSelected: Bool
    let gradientColors: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: isSelected ? gradientColors : [Color(UIColor.tertiarySystemFill)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: service.iconName)
                            .foregroundColor(isSelected ? .white : .gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? gradientColors[0] : .secondary)
                        .font(.title3)
                }
                
                Text(service.name)
                    .font(.headline)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Text("+ $\((service.price as NSDecimalNumber).doubleValue, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? gradientColors[0] : .secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .shadow(color: isSelected ? gradientColors[0].opacity(0.3) : Color.black.opacity(0.1),
                    radius: isSelected ? 10 : 5,
                    x: 0,
                    y: isSelected ? 5 : 2)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: isSelected ? gradientColors : [Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .frame(height: 150)
    }
}

struct HomeCleaningAdditionalView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeCleaningAdditionalView(cleaningDetails: OrderHomeCleaningViewModel())
                .preferredColorScheme(.light)
        }
        
        NavigationView {
            HomeCleaningAdditionalView(cleaningDetails: OrderHomeCleaningViewModel())
                .preferredColorScheme(.dark)
        }
    }
}
