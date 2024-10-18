import SwiftUI

struct OrdersActiveView: View {
    @StateObject private var viewModel = OrdersActiveViewModel()
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    OrdersLoadingView()
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage, retryAction: { Task { await viewModel.fetchOrders() } })
                } else if viewModel.orders.isEmpty {
                    NoOrdersView()
                } else {
                    orderList
                }
            }
            .navigationTitle("Order History")
            .background(Color(UIColor.systemGroupedBackground))
        }
        .task {
            await viewModel.fetchOrders()
        }
    }

    private var orderList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.orders) { orderInfo in
                    OrderTileView(orderInfo: orderInfo, toggleExpansion: viewModel.toggleExpansion, cancelOrder: { Task { await viewModel.cancelOrder(orderId: orderInfo.id) } })
                }
            }
            .padding()
        }
    }
}

struct NoOrdersView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("😿")
                .font(.system(size: 80))
            Text("You have no orders yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Make a new booking to get started!")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}

struct OrderTileView: View {
    let orderInfo: OrderWithWorkerInfo
    let toggleExpansion: (UUID) -> Void
    let cancelOrder: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingCancelConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ZStack(alignment: .bottom) {
                    AsyncImage(url: URL(string: orderInfo.worker.photoUrl)) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    
                    RatingBadge(rating: orderInfo.worker.rating)
                        .offset(y: 8)
                }
                .frame(width: 50, height: 58)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        StatusBadge(status: orderInfo.order.status)
                        Spacer()
                        if !orderInfo.order.isCompleted {
                            Button("Cancel") {
                                showingCancelConfirmation = true
                            }
                            .foregroundColor(.red)
                        }
                    }

                    Text(orderInfo.order.type)
                        .font(.headline)

                    HStack {
                        Image(systemName: "calendar")
                        Text(orderInfo.formattedDate)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }

            HStack {
                Text("$")
                    .foregroundColor(.blue)
                    .font(.title2)
                    .fontWeight(.bold) +
                Text(orderInfo.formattedPrice.dropFirst())
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        toggleExpansion(orderInfo.id)
                    }
                }) {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(orderInfo.isExpanded ? 180 : 0))
                }
            }

            if orderInfo.isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    DetailRow(icon: "person", text: orderInfo.worker.fullName)
                    DetailRow(icon: "mappin", text: orderInfo.order.address)
                    DetailRow(icon: "clock", text: "Duration: ~\(orderInfo.formattedDuration)")
                    if let instructions = orderInfo.order.specialInstructions {
                        DetailRow(icon: "text.justifyleft", text: "\(instructions)")
                    }
                    if !orderInfo.cleaningSupplies.isEmpty {
                        DetailRow(icon: "plus.circle", text: "Special Requests:")
                        ForEach(orderInfo.cleaningSupplies, id: \.self) { supply in
                            Text("• \(supply)")
                                .padding(.leading, 18)
                        }
                    }
                }
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .alert("Cancel Order", isPresented: $showingCancelConfirmation) {
            Button("Yes, Cancel", role: .destructive, action: cancelOrder)
            Button("No", role: .cancel) { }
        } message: {
            Text("Are you sure you want to cancel this order?")
        }
    }
}

struct StatusBadge: View {
    let status: String

    var body: some View {
        Text(status)
            .font(.caption)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(4)
    }
    
    private var statusColor: Color {
        switch status.lowercased() {
        case "confirmed": return .green
        case "pending": return .orange
        case "completed": return .blue
        case "cancelled": return .red
        default: return .gray
        }
    }
}

struct RatingBadge: View {
    let rating: Double
    
    var body: some View {
        HStack(spacing: 2) {
            Text(String(format: "%.1f", rating))
                .font(.system(size: 10, weight: .bold))
            Image(systemName: "star.fill")
                .font(.system(size: 8))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.yellow)
        .foregroundColor(.black)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
    }
}

struct DetailRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(text)
        }
    }
}

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Error")
                .font(.title)
                .foregroundColor(.red)
            Text(message)
                .multilineTextAlignment(.center)
            Button("Retry") {
                retryAction()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

struct OrdersActiveView_Previews: PreviewProvider {
    static var previews: some View {
        OrdersActiveView()
        
        NoOrdersView()
            .previewDisplayName("No Orders View")
    }
}
