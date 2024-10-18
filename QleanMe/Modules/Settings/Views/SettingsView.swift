import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Form {
            Section(header: Text("Notifications")) {
                Toggle("Enable Notifications", isOn: $viewModel.notificationsEnabled)
                    .onChange(of: viewModel.notificationsEnabled) { oldValue, newValue in
                        viewModel.updateNotifications(newValue)
                    }
            }
            
            Section(header: Text("Auto Tipping")) {
                Toggle("Enable Auto Tipping", isOn: $viewModel.autoTippingEnabled)
                    .onChange(of: viewModel.autoTippingEnabled) { oldValue, newValue in
                        viewModel.updateAutoTipping(newValue)
                    }
                
                if viewModel.autoTippingEnabled {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tip Percentage: \(Int(viewModel.autoTipPercentage))%")
                        Slider(value: $viewModel.autoTipPercentage, in: 0...30, step: 1)
                            .accentColor(.blue)
                            .onChange(of: viewModel.autoTipPercentage) { oldValue, newValue in
                                viewModel.updateAutoTipPercentage(newValue)
                            }
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .background(Color(UIColor.systemGroupedBackground))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
        .preferredColorScheme(.light)
        
        NavigationView {
            SettingsView()
        }
        .preferredColorScheme(.dark)
    }
}
