import SwiftUI
import Combine

struct RegisteredUserDashboardView: View {
    @StateObject private var viewModel = RegisteredUserDashboardViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationView {
                ZStack {
                    Group {
                        switch viewModel.activeView {
                        case .main:
                            MainDashboardContent(viewModel: viewModel)
                        case .orderHistory:
                            OrdersActiveView()
                                .navigationTitle("Order History")
                        case .notifications:
                            NotificationListView()
                                .navigationTitle("Notifications")
                        case .profile:
                            CustomerProfileView()
                        }
                    }
                }
            }
            
            CustomTabBar(
                selectedTab: $viewModel.selectedTab,
                tabs: [
                    "house.fill",
                    "plus.circle.fill",
                    "person.fill"
                ],
                action: { index in
                    handleTabSelection(index)
                }
            )
        }
        .sheet(isPresented: $viewModel.showOrderCreation) {
            OrderCreationSupportingView()
        }
        .sheet(isPresented: $viewModel.showOfferDetails) {
            if let selectedOffer = viewModel.selectedOffer {
                NavigationView {
                    OfferDetailsView(offer: selectedOffer)
                }
            }
        }
        .sheet(isPresented: $viewModel.showReferralProgram) {
            ReferralProgramView()
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
    
    private func handleTabSelection(_ index: Int) {
        switch index {
        case 0:
            viewModel.showMainDashboard()
        case 1:
            viewModel.showOrderCreation = true
        case 2:
            viewModel.showProfile()
        default:
            break
        }
    }
}

// MARK: - Main Dashboard Content
struct MainDashboardContent: View {
    @ObservedObject var viewModel: RegisteredUserDashboardViewModel
    @State private var scrollOffset: CGFloat = 0
    private let titleScrollThreshold: CGFloat = 100
    
    private let gradientColors = [
        Color(hex: 0x4776E6),
        Color(hex: 0x8E54E9)
    ]
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView(showsIndicators: false) {
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geometry.frame(in: .named("scroll")).minY
                    )
                }
                .frame(height: 0)
                
                VStack(spacing: 32) {
                    if viewModel.isLoading {
                        loadingView
                    } else {
                        welcomeSection
                        offersSection
                        ordersSection
                        
                        Spacer(minLength: 100)
                    }
                }
                .padding(.horizontal)
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                withAnimation(.easeInOut(duration: 0.2)) {
                    scrollOffset = value
                }
            }
            .refreshable {
                await viewModel.fetchOrders()
            }
        }
        .navigationTitle("Welcome")
        .navigationBarTitleDisplayMode(scrollOffset < -titleScrollThreshold ? .inline : .large)
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .frame(maxWidth: .infinity, minHeight: 200)
            Text("Loading your dashboard...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if scrollOffset >= -titleScrollThreshold {
                Text(viewModel.userName)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            Text("What can we help you with today?")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, scrollOffset >= -titleScrollThreshold ? 0 : 16)
        .opacity(scrollOffset >= -titleScrollThreshold ? 1 : 0)
    }
    
    private var offersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            TabView(selection: $viewModel.currentOfferIndex) {
                ForEach(viewModel.offers.indices, id: \.self) { index in
                    OfferCard(offer: viewModel.offers[index]) {
                        viewModel.selectOffer(viewModel.offers[index])
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }
    
    private var ordersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "clock.circle.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Orders")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Picker("Order Filter", selection: $viewModel.selectedOrderFilter) {
                    Text(OrderFilterType.active.title).tag(OrderFilterType.active)
                    Text(OrderFilterType.archive.title).tag(OrderFilterType.archive)
                }
                .pickerStyle(.segmented)
                .frame(width: 160)
            }
            .padding(.horizontal, 4)
            
            if !viewModel.hasOrders {
                EmptyOrdersView(
                    emoji: viewModel.emptyStateEmoji,
                    title: viewModel.emptyStateTitle,
                    message: viewModel.emptyStateMessage,
                    buttonTitle: viewModel.emptyStateButtonTitle,
                    viewModel: viewModel
                )
            } else {
                OrdersList(
                    orders: viewModel.filteredOrders,
                    onCancelOrder: { orderId in
                        Task {
                            await viewModel.cancelOrder(orderId)
                        }
                    }
                )
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(UIColor.systemBackground),
                Color(UIColor.systemBackground).opacity(0.95)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Supporting Views
struct OrdersList: View {
    let orders: [OrderWithWorkerInfo]
    let onCancelOrder: (UUID) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(orders) { order in
                OrderTileView(
                    orderInfo: order,
                    toggleExpansion: { _ in },
                    cancelOrder: {
                        onCancelOrder(order.id)
                    }
                )
            }
        }
    }
}

struct EmptyOrdersView: View {
    let emoji: String
    let title: String
    let message: String
    let buttonTitle: String
    @ObservedObject var viewModel: RegisteredUserDashboardViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text(emoji)
                .font(.system(size: 64))
            
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if viewModel.showEmptyStateButton {
                Button(action: {
                    viewModel.showOrderCreation = true
                }) {
                    Text(buttonTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: 0x4776E6), Color(hex: 0x8E54E9)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
            }
        }
        .padding(32)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}

struct OfferCard: View {
    let offer: DashboardOffer
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(offer.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(offer.emoji)
                        .font(.title)
                }
                
                Text(offer.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
                
                HStack {
                    Text("View Details")
                        .font(.callout)
                        .fontWeight(.medium)
                    Image(systemName: "arrow.right")
                        .font(.callout)
                }
                .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            Color(hex: UInt(offer.backgroundColor.dropFirst(), radix: 16) ?? 0x4CAF50),
                            Color(hex: UInt(offer.backgroundColor.dropFirst(), radix: 16) ?? 0x4CAF50).opacity(0.8)
                        ]
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Supporting Types
private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview Provider
struct RegisteredUserDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RegisteredUserDashboardView()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            RegisteredUserDashboardView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
            
            EmptyOrdersView(
                emoji: "🏃",
                title: "No active orders",
                message: "Ready to schedule your first cleaning?",
                buttonTitle: "Book Now",
                viewModel: RegisteredUserDashboardViewModel()
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Empty State")
        }
    }
}
