import SwiftUI

struct OrderHomeCleaningView: View {
    @StateObject private var viewModel = OrderHomeCleaningViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var showAdditionalDetails = false
    
    private let gradientColors = [Color(hex: 0x2193b0), Color(hex: 0x6dd5ed)]
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    cleaningTypeSection
                    roomsSection
                    propertySizeSection
                    if viewModel.selectedCleaningType != .moveInOut {
                        additionalServicesSection
                    }
                    
                    Color.clear.frame(height: 100)
                }
                .padding()
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        gradientColors[0].opacity(0.1),
                        gradientColors[1].opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            
            VStack {
                Spacer()
                bottomBar
            }
        }
        .navigationTitle("Home Cleaning")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showAdditionalDetails) {
            HomeCleaningAdditionalView(cleaningDetails: viewModel)
        }
    }
    
    private var cleaningTypeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Type of Cleaning")
                .font(.headline)
            
            ForEach(HomeCleaningType.allCases) { type in
                CleaningTypeCard(
                    type: type,
                    isSelected: viewModel.selectedCleaningType == type,
                    gradientColors: gradientColors
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.selectedCleaningType = type
                    }
                }
            }
        }
    }
    
    private var roomsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Rooms")
                .font(.headline)
            
            VStack(spacing: 16) {
                RoomCountSelector(
                    title: "Bedrooms",
                    count: viewModel.numberOfBedrooms,
                    increment: { viewModel.incrementValue(for: .bedroom) },
                    decrement: { viewModel.decrementValue(for: .bedroom) },
                    gradientColors: gradientColors
                )
                
                RoomCountSelector(
                    title: "Bathrooms",
                    count: viewModel.numberOfBathrooms,
                    increment: { viewModel.incrementValue(for: .bathroom) },
                    decrement: { viewModel.decrementValue(for: .bathroom) },
                    gradientColors: gradientColors
                )
                
                RoomCountSelector(
                    title: "Other Rooms",
                    subtitle: "Living rooms, dens, etc.",
                    count: viewModel.numberOfRooms,
                    increment: { viewModel.incrementValue(for: .other) },
                    decrement: { viewModel.decrementValue(for: .other) },
                    gradientColors: gradientColors
                )
            }
        }
    }
    
    private var propertySizeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Property Size")
                .font(.headline)
            
            HStack(spacing: 12) {
                ForEach(PropertySize.allCases) { size in
                    PropertySizeCard(
                        size: size,
                        isSelected: viewModel.selectedSize == size,
                        gradientColors: gradientColors
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.selectedSize = size
                        }
                    }
                }
            }
        }
    }
    
    private var additionalServicesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What else needs attention?")
                .font(.headline)
            
            let columns = [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ]
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(AdditionalService.available) { service in
                    AdditionalServiceCard(
                        service: service,
                        isSelected: viewModel.selectedAdditionalServices.contains(service.id),
                        gradientColors: gradientColors
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.toggleAdditionalService(service.id)
                        }
                    }
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
                    Text("$\((viewModel.totalPrice as NSDecimalNumber).doubleValue, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Button(action: {
                    showAdditionalDetails = true
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
                            gradient: Gradient(colors: gradientColors),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
            .background(.ultraThinMaterial)
        }
    }
}

struct OrderHomeCleaningView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OrderHomeCleaningView()
                .preferredColorScheme(.light)
        }
        
        NavigationView {
            OrderHomeCleaningView()
                .preferredColorScheme(.dark)
        }
    }
}
