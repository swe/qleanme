import SwiftUI

struct OrderCreationView: View {
    @State private var selectedService: OrderServiceType?
    @State private var showServiceDetails = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    private var navigationTitle: String {
        if showServiceDetails, let service = selectedService {
            return "Order \(service.shortTitle)"
        } else {
            return "Select service"
        }
    }
    
    var body: some View {
        VStack {
            if !showServiceDetails {
                serviceSelectionView
            } else if let service = selectedService {
                serviceDetailsView(for: service)
            }
        }
        .navigationBarBackButtonHidden(showServiceDetails)
        .navigationBarTitle(navigationTitle, displayMode: .inline)
        .toolbar {
            if showServiceDetails {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation {
                            showServiceDetails = false
                        }
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }
            }
        }
    }
    
    private var serviceSelectionView: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(OrderServiceType.allCases) { service in
                        OrderSelectionCard(service: service, isSelected: selectedService == service) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedService = service
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 25)
            }
            
            Button(action: {
                withAnimation {
                    showServiceDetails = true
                }
            }) {
                HStack {
                    Text("Continue")
                        .fontWeight(.semibold)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    Group {
                        if let service = selectedService {
                            LinearGradient(
                                gradient: Gradient(colors: service.gradientColors),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            Color.gray.opacity(0.3)
                        }
                    }
                )
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(selectedService == nil)
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
    }
    
    @ViewBuilder
        private func serviceDetailsView(for service: OrderServiceType) -> some View {
            switch service {
            case .cleaning:
                OrderHomeCleaningView()
            case .laundry:
                OrderLaundryView()
        default:
            VStack(spacing: 20) {
                Image(systemName: "wrench.and.screwdriver")
                    .font(.system(size: 50))
                    .foregroundColor(.secondary)
                Text("Coming Soon!")
                    .font(.title)
                    .foregroundColor(.secondary)
                Text("This service will be available shortly.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }
}

struct OrderSelectionCard: View {
    let service: OrderServiceType
    let isSelected: Bool
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: service.gradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    
                    Image(systemName: service.iconName)
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(service.rawValue)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(service.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                    .opacity(isSelected ? 1 : 0.5)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: isSelected ? service.gradientColors : [Color.clear]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1),
                    radius: isSelected ? 10 : 5,
                    x: 0,
                    y: isSelected ? 5 : 2)
            .scaleEffect(isSelected ? 1.02 : 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OrderCreationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OrderCreationView()
                .preferredColorScheme(.light)
            
            OrderCreationView()
                .preferredColorScheme(.dark)
        }
    }
}
