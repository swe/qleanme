import Foundation
import StoreKit

class AboutViewModel: ObservableObject {
    @Published var appVersion: String = ""
    @Published var buildNumber: String = ""
    
    let companyStory: String = """
    QleanMe was founded in Vancouver with a vision to revolutionize the cleaning industry. Our mission is to provide top-quality, eco-friendly cleaning services that make our customers' lives easier and their homes healthier.

    Starting from a small team, we've grown to serve Vancouver and Victoria, always maintaining our commitment to excellence, sustainability, and customer satisfaction.

    At QleanMe, we're not just cleaning homes; we're building a community of happy customers and empowered cleaning professionals. We're committed to fair wages, environmentally friendly practices, and continuous improvement in everything we do.

    Thank you for being a part of our journey. Together, we're making the world a cleaner, brighter place, one home at a time.
    """
    
    let regulatoryLinks: [(String, String)] = [
        ("Terms of Service", "https://qlean.me/terms"),
        ("Privacy Policy", "https://qlean.me/privacy"),
        ("Cleaning Standards", "https://qlean.me/cleaning-standards")
    ]
    
    init() {
        fetchAppInfo()
    }
    
    private func fetchAppInfo() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            appVersion = version
        }
        
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            buildNumber = build
        }
    }
    
    func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            Task {
                await AppStore.requestReview(in: windowScene)
            }
        }
    }
}
