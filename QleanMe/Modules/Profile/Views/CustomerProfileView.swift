import SwiftUI
import MessageUI

struct CustomerProfileView: View {
    @StateObject private var viewModel = CustomerProfileViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @State private var isEditProfileActive = false
    
    private let gradientColors = [
        Color(hex: 0x4776E6),
        Color(hex: 0x8E54E9)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.top, 100)
                    } else {
                        VStack(spacing: 24) {
                            profileHeader
                            statisticsCard
                            menuItems
                            logoutButton
                            footerText
                        }
                        .padding()
                        .padding(.bottom, 110)
                    }
                }
                .navigationTitle("My profile")
                .background(Color(UIColor.systemBackground))
                
                if viewModel.isLoggingOut {
                    ProgressView("Logging out...")
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            }
            .sheet(isPresented: $viewModel.showReferralProgram) {
                ReferralProgramView()
            }
            .sheet(isPresented: $viewModel.showMailComposer) {
                MailView(
                    result: { result in
                        viewModel.showMailComposer = false
                    }
                )
            }
            .alert(isPresented: $viewModel.showLogoutConfirmation) {
                Alert(
                    title: Text("Logout"),
                    message: Text("Are you sure you want to logout?"),
                    primaryButton: .destructive(Text("Logout")) {
                        viewModel.logout()
                    },
                    secondaryButton: .cancel {
                        viewModel.cancelLogout()
                    }
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
            .fullScreenCover(isPresented: $viewModel.shouldNavigateToWelcome) {
                WelcomeView()
                    .transition(.move(edge: .trailing))
            }
            .onAppear {
                viewModel.fetchUserData()
            }
        }
    }
    
    private var profileHeader: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: viewModel.profileImage)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.userName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(viewModel.formattedPhoneNumber)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var statisticsCard: some View {
        HStack(spacing: 0) {
            statisticItem(value: "\(viewModel.completedOrders)", label: "Completed\nOrders")
            Divider().frame(height: 40)
            statisticItem(value: String(format: "%.1f", viewModel.averageRating), label: "Average\nRating", showStar: true)
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(16)
        .shadow(color: Color.primary.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func statisticItem(value: String, label: String, showStar: Bool = false) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                if showStar {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 14))
                }
            }
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var menuItems: some View {
        VStack(spacing: 0) {
            Group {
                NavigationLink(
                    destination: CustomerEditProfileView()
                        .onDisappear {
                            viewModel.fetchUserData()
                        }
                        .environment(\.hideTabBar, true)
                ) {
                    menuItemContent(icon: "person.crop.circle", title: "Profile details")
                }
                Divider()
                //  NavigationLink(destination: SettingsView()) {
                //      menuItemContent(icon: "gearshape", title: "Settings")
                //  }
                //  Divider()
                menuItem(icon: "gift", title: "Refer a friend", action: viewModel.navigateToReferralProgram)
                Divider()
                NavigationLink(destination: AboutView()) {
                    menuItemContent(icon: "info.circle", title: "About")
                }
                Divider()
                NavigationLink(destination: FAQView()) {
                    menuItemContent(icon: "questionmark.circle", title: "FAQ")
                }
                Divider()
                menuItem(icon: "headphones", title: "Support", action: viewModel.navigateToSupport)
            }
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.primary.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func menuItem(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            menuItemContent(icon: icon, title: title)
        }
    }
    
    private func menuItemContent(icon: String, title: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
                .font(.system(size: 18))
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.system(size: 14))
        }
        .padding(.vertical, 14)
        .padding(.horizontal)
    }
    
    private var logoutButton: some View {
        Button(action: {
            viewModel.initiateLogout()
        }) {
            HStack {
                Spacer()
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Logout")
                Spacer()
            }
            .padding()
            .background(Color.red.opacity(colorScheme == .dark ? 0.3 : 0.1))
            .foregroundColor(.red)
            .cornerRadius(16)
        }
        .padding(.top, 20)
    }
    
    private var footerText: some View {
        Text("Made with ❤️ in Vancouver, BC, Canada")
            .font(.footnote)
            .foregroundStyle(
                LinearGradient(
                    gradient: Gradient(colors: [.purple, .blue]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .multilineTextAlignment(.center)
            .padding(.top, 8)
    }
}

struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    let result: (Result<MFMailComposeResult, Error>) -> Void
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding private var presentationMode: PresentationMode
        let result: (Result<MFMailComposeResult, Error>) -> Void
        
        init(presentationMode: Binding<PresentationMode>,
             result: @escaping (Result<MFMailComposeResult, Error>) -> Void) {
            _presentationMode = presentationMode
            self.result = result
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                 didFinishWith result: MFMailComposeResult,
                                 error: Error?) {
            if let error = error {
                self.result(.failure(error))
            } else {
                self.result(.success(result))
            }
            $presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: presentationMode, result: result)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = context.coordinator
        mailComposer.setToRecipients(["support@qleanme.com"])
        mailComposer.setSubject("QleanMe Support Request")
        return mailComposer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                              context: UIViewControllerRepresentableContext<MailView>) {
    }
}

struct CustomerProfileView_Previews: PreviewProvider {
    static var previews: some View {
        CustomerProfileView()
            .preferredColorScheme(.light)
        
        CustomerProfileView()
            .preferredColorScheme(.dark)
    }
}
