import SwiftUI
import MapKit

struct IdentifiableLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct OrderCleaningLocationPickerView: View {
    @StateObject private var viewModel = OrderCleaningLocationPickerViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    private let gradientColors = [Color(hex: 0x2193b0), Color(hex: 0x6dd5ed)]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Search Bar
                    SearchBar(text: $viewModel.searchText, gradientColors: gradientColors)
                        .padding(.horizontal)
                    
                    ZStack {
                        // Map Container
                        ZStack {
                            // Map
                            Map(coordinateRegion: $viewModel.region,
                                showsUserLocation: true,
                                annotationItems: [viewModel.selectedLocation].compactMap { location in
                                    location.map { IdentifiableLocation(coordinate: $0) }
                                }
                            ) { location in
                                MapMarker(coordinate: location.coordinate)
                            }
                            .gesture(
                                DragGesture()
                                    .onEnded { _ in
                                        if viewModel.selectionType == .pin {
                                            viewModel.selectedLocation = viewModel.region.center
                                        }
                                    }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        LinearGradient(
                                            colors: gradientColors,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            .padding(.horizontal, 20)
                            
                            if viewModel.selectionType == .pin {
                                // Center Pin
                                Image(systemName: "mappin")
                                    .font(.system(size: 24))
                                    .foregroundColor(gradientColors[0])
                                    .offset(y: -12)
                            }
                            
                            // Map Controls
                            VStack(spacing: 12) {
                                Spacer()
                                HStack {
                                    Spacer()
                                    VStack(spacing: 12) {
                                        MapControlButton(
                                            icon: "location.circle.fill",
                                            colors: gradientColors,
                                            isSelected: viewModel.selectionType == .current
                                        ) {
                                            viewModel.getCurrentLocation()
                                        }
                                        
                                        MapControlButton(
                                            icon: "mappin.circle.fill",
                                            colors: gradientColors,
                                            isSelected: viewModel.selectionType == .pin
                                        ) {
                                            viewModel.setLocationPin()
                                        }
                                    }
                                    .padding(.trailing, 32)
                                    .padding(.bottom, 32)
                                }
                            }
                        }
                        .opacity(viewModel.searchText.isEmpty ? 1 : 0.3)
                        
                        // Search Results
                        if !viewModel.searchText.isEmpty {
                            searchResultsList
                                .transition(.opacity)
                        }
                    }
                    
                    // Location confirmation section
                    VStack(spacing: 8) {
                        if !viewModel.currentAddress.isEmpty && viewModel.selectionType == .pin {
                            Text(viewModel.currentAddress)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        // Confirm Location Button
                        Button(action: {
                            if let locationData = viewModel.sendLocation() {
                                // Handle the location data as needed
                                print("Selected location: \(locationData.coordinate)")
                                print("Address: \(locationData.address)")
                                dismiss()
                            }
                        }) {
                            HStack {
                                Text(viewModel.selectionType == .current ? "Send current location" :
                                        viewModel.selectionType == .pin ? "Send location" : "Confirm Location")
                                    .fontWeight(.semibold)
                                Image(systemName: "arrow.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: viewModel.selectedLocation != nil ? gradientColors : [Color.gray.opacity(0.3)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        .disabled(viewModel.selectedLocation == nil)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .fontWeight(.medium)
                            .foregroundColor(gradientColors[0])
                    }
                }
            }
        }
        .onAppear {
            viewModel.requestLocationPermission()
        }
    }
    
    private var searchResultsList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(viewModel.searchResults, id: \.self) { item in
                    SearchResultRow(item: item) {
                        viewModel.region = MKCoordinateRegion(
                            center: item.placemark.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                        viewModel.selectedLocation = item.placemark.coordinate
                        viewModel.selectionType = .pin
                        viewModel.searchText = ""
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 8)
        }
        .background(Color(UIColor.systemBackground).opacity(0.98))
    }
}

struct MapControlButton: View {
    let icon: String
    let colors: [Color]
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: isSelected ? [.white] : colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(
                            isSelected ?
                            LinearGradient(
                                colors: colors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color(UIColor.systemBackground)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
                )
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    let gradientColors: [Color]
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(gradientColors[0])
            
            TextField("Search location", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(UIColor.separator), lineWidth: 0.5)
        )
    }
}

struct SearchResultRow: View {
    let item: MKMapItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name ?? "Unknown location")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    if let address = item.placemark.thoroughfare {
                        Text(address)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}

struct OrderCleaningLocationPickerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OrderCleaningLocationPickerView()
                .preferredColorScheme(.light)
            
            OrderCleaningLocationPickerView()
                .preferredColorScheme(.dark)
        }
    }
}
