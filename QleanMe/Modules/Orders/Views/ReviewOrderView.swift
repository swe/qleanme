import SwiftUI
import MapKit

struct ReviewOrderView: View {
    @StateObject var viewModel: ReviewOrderViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    private let gradientColors = [Color(hex: 0x2193b0), Color(hex: 0x6dd5ed)]
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    orderDetailsSection
                    locationSection
                    dateTimeSection
                    additionalDetailsSection
                    pricingSummarySection
                    
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
        .navigationTitle("Review Order")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if viewModel.isProcessingPayment {
                LoadingView()
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") {
                viewModel.showError = false
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .sheet(isPresented: $viewModel.showStripePaymentSheet) {
            PaymentSheetView(clientSecret: viewModel.paymentIntentClientSecret ?? "") { result in
                Task {
                    switch result {
                    case .success:
                        await viewModel.handlePaymentSuccess()
                    case .failure(let error):
                        await viewModel.handlePaymentFailure(error)
                    }
                }
            }
        }
        .navigationDestination(isPresented: $viewModel.showPaymentSuccess) {
            OrderConfirmationView {
                // Navigate back to root view
                dismiss()
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                gradientColors[0].opacity(0.1),
                gradientColors[1].opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var orderDetailsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section Header
            SectionHeader(icon: "list.bullet", title: "Order Details", gradientColors: gradientColors)

            VStack(spacing: 16) {
                ForEach(viewModel.orderItems) { item in
                    OrderItemRow(
                        title: item.title,
                        subtitle: item.subtitle,
                        price: item.price,
                        icon: item.icon,
                        gradientColors: gradientColors
                    )
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(icon: "location.fill", title: "Location", gradientColors: gradientColors)
            
            VStack(spacing: 16) {
                // Address
                HStack(alignment: .top) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.title2)
                        .foregroundColor(gradientColors[0])
                    
                    Text(viewModel.formattedAddress)
                        .font(.body)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Map
                if let coordinate = viewModel.locationCoordinate {
                    Map(position: .constant(.region(MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )))) {
                        Marker("Service Location", coordinate: coordinate)
                    }
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(true)
                } else {
                    ProgressView()
                        .frame(height: 180)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
    
    private var dateTimeSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(icon: "calendar", title: "Date & Time", gradientColors: gradientColors)
            
            HStack {
                Image(systemName: "clock.fill")
                    .font(.title2)
                    .foregroundColor(gradientColors[0])
                
                Text(viewModel.formattedDate)
                    .font(.body)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
    
    private var additionalDetailsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(icon: "text.bubble.fill", title: "Additional Details", gradientColors: gradientColors)
            
            let details = viewModel.additionalDetails
            
            VStack(alignment: .leading, spacing: 16) {
                if let hasPets = details["hasPets"] as? Bool, hasPets,
                   let petDetails = details["petDetails"] as? String {
                    OrderDetailRow(
                        icon: "pawprint.fill",
                        title: "Pets",
                        value: petDetails,
                        colors: gradientColors
                    )
                }
                
                if let cleaningSupplies = details["cleaningSupplies"] as? String {
                    OrderDetailRow(
                        icon: "spray.bottle.fill",
                        title: "Cleaning Supplies",
                        value: cleaningSupplies,
                        colors: gradientColors
                    )
                }
                
                if let hasVacuum = details["hasVacuum"] as? Bool {
                    OrderDetailRow(
                        icon: "vacuum.fill",
                        title: "Vacuum",
                        value: hasVacuum ? "Available" : "Not Available",
                        colors: gradientColors
                    )
                }
                
                if let instructions = details["specialInstructions"] as? String,
                   !instructions.isEmpty {
                    OrderDetailRow(
                        icon: "note.text",
                        title: "Special Instructions",
                        value: instructions,
                        colors: gradientColors
                    )
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
    
    private var pricingSummarySection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(icon: "dollarsign.circle.fill", title: "Pricing Summary", gradientColors: gradientColors)
            
            VStack(spacing: 12) {
                ForEach(viewModel.orderItems) { item in
                    if let price = item.price {
                        HStack {
                            Text(item.title)
                                .font(.subheadline)
                            Spacer()
                            Text(viewModel.formatPrice(price))
                                .font(.subheadline)
                        }
                    }
                }
                
                Divider()
                    .padding(.vertical, 8)
                
                HStack {
                    Text("Total")
                        .font(.headline)
                    Spacer()
                    Text(viewModel.formattedTotal)
                        .font(.headline)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
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
                    Text(viewModel.formattedTotal)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Button(action: {
                    Task {
                        await viewModel.processOrder()
                    }
                }) {
                    HStack {
                        if viewModel.isProcessingPayment {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Proceed to Payment")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }
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
                .disabled(viewModel.isProcessingPayment)
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
            .background(.ultraThinMaterial)
        }
    }
}

// MARK: - Supporting Views

struct OrderDetailRow: View {
    let icon: String
    let title: String
    let value: String
    let colors: [Color]  // Changed from gradientColors to colors to match the initialization
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(
                    LinearGradient(
                        colors: colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }
        }
    }
}

struct OrderItemRow: View {
    let title: String
    let subtitle: String?
    let price: Decimal?
    let icon: String
    let gradientColors: [Color]
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(gradientColors[0].opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: icon)
                        .foregroundStyle(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if let price = price {
                Text(formatPrice(price))
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func formatPrice(_ price: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: price as NSDecimalNumber) ?? "$0.00"
    }
}

struct OrderConfirmationView: View {
    let onDismiss: () -> Void
    private let gradientColors = [Color(hex: 0x2193b0), Color(hex: 0x6dd5ed)]
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text("Order Confirmed!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Your order has been confirmed and our team will be there at the scheduled time.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: onDismiss) {
                Text("Back to Dashboard")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top, 24)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Payment Sheet View (Mock)
struct PaymentSheetView: View {
    let clientSecret: String
    let onCompletion: (Result<Void, Error>) -> Void
    
    var body: some View {
        Text("Payment Sheet Mock")
            .onAppear {
                // Simulate successful payment after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    onCompletion(.success(()))
                }
            }
    }
}
