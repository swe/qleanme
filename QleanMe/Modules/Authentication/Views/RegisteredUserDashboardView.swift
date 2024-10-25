import SwiftUI

struct RegisteredUserDashboardView: View {
    @StateObject private var viewModel = RegisteredUserDashboardViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @State private var showOrderCreationView = false
    @State private var isTabBarHidden = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Group {
                    switch viewModel.activeView {
                    case .main:
                        mainDashboardView
                    case .orderHistory:
                        OrdersActiveView()
                    case .notifications:
                        NotificationListView()
                    case .profile:
                        CustomerProfileView()
                    }
                }
                
                VStack {
                    Spacer()
                    CustomTabBar(selectedTab: $viewModel.selectedTab, tabs: [
                        "house.circle",
                        "tray.circle",
                        "plus",
                        "bell.circle",
                        "person.circle"
                    ], action: { index in
                        switch index {
                        case 0:
                            viewModel.showMainDashboard()
                        case 1:
                            viewModel.showOrderHistory()
                        case 2:
                            showOrderCreationView = true
                        case 3:
                            viewModel.showNotifications()
                        case 4:
                            viewModel.showProfile()
                        default:
                            break // Handle other tabs as needed
                        }
                    })
                }
            }
            .sheet(isPresented: $showOrderCreationView) {
                OrderCreationSupportingView()
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }

    
    private var mainDashboardView: some View {
        ScrollView {
            VStack(spacing: 20) {
                welcomeSection
                offerCarousel
                orderCleaningButton
            }
            .padding()
        }
        .background(colorScheme == .dark ? Color.black : Color.gray.opacity(0.1))
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Welcome, \(viewModel.userName)!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("What are your plans for today?")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var offerCarousel: some View {
        TabView(selection: $viewModel.currentOfferIndex) {
            ForEach(viewModel.offers.indices, id: \.self) { index in
                offerCard(for: viewModel.offers[index])
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .frame(height: 200)
        .cornerRadius(15)
        .animation(.easeInOut, value: viewModel.currentOfferIndex)
    }
    
    private func offerCard(for offer: Offer) -> some View {
        ZStack(alignment: .bottomLeading) {
            Image(offer.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped()
            
            VStack(alignment: .leading, spacing: 5) {
                Text(offer.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(offer.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]), startPoint: .bottom, endPoint: .top))
        }
    }
    
    private var orderCleaningButton: some View {
        Button(action: viewModel.orderCleaning) {
            HStack {
                Image(systemName: "sparkles")
                Text("Order Cleaning")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

struct RegisteredUserDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RegisteredUserDashboardView()
                .preferredColorScheme(.light)
            
            RegisteredUserDashboardView()
                .preferredColorScheme(.dark)
        }
    }
}
