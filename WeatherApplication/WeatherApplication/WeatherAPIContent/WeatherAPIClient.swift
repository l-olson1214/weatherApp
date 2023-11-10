//
//  WeatherAPIClient.swift
//  WeatherApplication
//
//  Created by Grey Olson on 11/9/23.
//
import Foundation
import CoreLocation
import SwiftUI

final class WeatherAPIClient: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentWeather: Weather?
    
    private let locationManager = CLLocationManager()
    private let dateFormatter = ISO8601DateFormatter()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestLocation()
    }

    func fetchWeather() async {
        guard let location = locationManager.location else {
            requestLocation()
            return
        }
        
        guard let url = URL(string: "https://api.tomorrow.io/v4/timelines?location=\(location.coordinate.latitude),\(location.coordinate.longitude)&fields=temperature&fields=weatherCode&units=metric&timesteps=1h&startTime=\(dateFormatter.string(from: Date()))&endTime=\(dateFormatter.string(from: Date().addingTimeInterval(60 * 60)))&apikey=810vUlL2cQo1b3TkXTOElNPPPf3Fdnsn") else {
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let weatherResponse = try? JSONDecoder().decode(WeatherModel.self, from: data),
               let weatherValue = weatherResponse.data.timelines.first?.intervals.first?.values,
               let weatherCode = WeatherCode(rawValue: "\(weatherValue.weatherCode)") {
                DispatchQueue.main.async { [weak self] in
                    self?.currentWeather = Weather(temperature: Int(weatherValue.temperature),
                                                   weatherCode: weatherCode)
                }
            }
        } catch {
            print("Error on 44")
            // handle the error
        }
    }
    
    private func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        print("Requesting Location")
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        if let location = locations.first {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            // Handle location update
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("Error: \(error)")
    }
}
