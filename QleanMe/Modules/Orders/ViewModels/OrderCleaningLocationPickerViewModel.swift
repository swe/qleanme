import MapKit
import Combine

enum LocationSelectionType {
    case current
    case pin
    case none
}

final class OrderCleaningLocationPickerViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region: MKCoordinateRegion
    @Published var searchText: String = ""
    @Published var selectedLocation: CLLocationCoordinate2D?
    @Published var searchResults: [MKMapItem] = []
    @Published var selectionType: LocationSelectionType = .none
    @Published var currentAddress: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    override init() {
        // Default to Vancouver/Burnaby area
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 49.2827, longitude: -123.1207),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        
        super.init()
        
        setupBindings()
        setupLocationManager()
    }
    
    private func setupBindings() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                self?.performSearch(with: searchText)
            }
            .store(in: &cancellables)
        
        $selectedLocation
            .sink { [weak self] location in
                if let location = location {
                    self?.reverseGeocodeLocation(location)
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() {
        selectionType = .current
        locationManager.requestLocation()
    }
    
    func setLocationPin() {
        selectionType = .pin
        selectedLocation = region.center
    }
    
    private func reverseGeocodeLocation(_ coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Reverse geocoding error: \(error.localizedDescription)")
                    self?.currentAddress = "Address not found"
                    return
                }
                
                if let placemark = placemarks?.first {
                    let address = [
                        placemark.subThoroughfare,
                        placemark.thoroughfare,
                        placemark.locality,
                        placemark.administrativeArea,
                        placemark.postalCode
                    ]
                        .compactMap { $0 }
                        .joined(separator: " ")
                    
                    self?.currentAddress = address
                } else {
                    self?.currentAddress = "Address not found"
                }
            }
        }
    }
    
    private func performSearch(with query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let response = response, error == nil else { return }
            
            DispatchQueue.main.async {
                self?.searchResults = response.mapItems
            }
        }
    }
    
    func sendLocation() -> (coordinate: CLLocationCoordinate2D, address: String)? {
        guard let location = selectedLocation else { return nil }
        return (location, currentAddress)
    }
    
    // MARK: - Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            self?.selectedLocation = location.coordinate
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
        DispatchQueue.main.async { [weak self] in
            self?.selectionType = .none
            self?.currentAddress = "Unable to get location"
        }
    }
}
