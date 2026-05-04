//
//  LocationManager.swift
//  WearlyWeather
//
//  Created by Anton Stremovskiy on 04.05.26.
//

// LocationManager.swift
import CoreLocation
import Combine

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var location: CLLocation?
    @Published var status: CLAuthorizationStatus = .notDetermined
    @Published var cityName: String = ""
    
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    func requestLocation() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            status = manager.authorizationStatus
        default:
            break
        }
    }
    
    func reverseGeocode(location: CLLocation, completion: @escaping (CLPlacemark?) -> Void) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            
            if let error = error {
                print("❌ Reverse geocode error: \(error.localizedDescription)")
                completion(nil)
            }
            
            if let firstPlacemark = placemarks?[0] {
                //print("📍Placemarks -> ", firstPlacemark.locality ?? "nothing")
                completion(firstPlacemark)
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        
        reverseGeocode(location: location, completion: { placemark in
            DispatchQueue.main.async {
                self.cityName = placemark?.locality ?? "Unknown"
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        }
    }
}
