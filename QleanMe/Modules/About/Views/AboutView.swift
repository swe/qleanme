import SwiftUI

struct AboutView: View {
    @StateObject private var viewModel = AboutViewModel()
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerView
                companyStoryView
                regulatoryLinksView
                rateAppButton
                versionInfo
            }
            .padding()
            .padding(.bottom, 110) // Increased padding at the bottom
        }
        .navigationTitle("About QleanMe")
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            Image("app_logo") // Make sure to add your app logo to the asset catalog
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .cornerRadius(20)
            
            Text("QleanMe")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
    
    private var companyStoryView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Our Story")
                .font(.headline)
                .fontWeight(.bold)
            
            Text(viewModel.companyStory)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var regulatoryLinksView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Legal & Regulatory")
                .font(.headline)
                .fontWeight(.bold)
            
            ForEach(viewModel.regulatoryLinks, id: \.0) { title, url in
                Button(action: {
                    openURL(URL(string: url)!)
                }) {
                    HStack {
                        Text(title)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.blue)
                    }
                }
                if title != viewModel.regulatoryLinks.last!.0 {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var rateAppButton: some View {
        Button(action: viewModel.rateApp) {
            HStack {
                Image(systemName: "star.fill")
                Text("Rate QleanMe on the App Store")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(12)
        }
    }
    
    private var versionInfo: some View {
        VStack {
            Text("App Version: \(viewModel.appVersion)")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            Text("© 2024 QleanMe Cleaning Inc. All rights reserved.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AboutView()
        }
        .preferredColorScheme(.light)
        
        NavigationView {
            AboutView()
        }
        .preferredColorScheme(.dark)
    }
}
