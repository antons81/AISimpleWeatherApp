//
//  HomeViewModel.swift
//  WearlyWeather
//
//  Created by Anton Stremovskiy on 04.05.26.
//

// HomeViewModel.swift
import Foundation
import Combine
import CoreLocation

@MainActor
final class HomeViewModel: ObservableObject {
    
    @Published var currentWeather: CurrentWeather?
    @Published var oneCall: OneCallResponse?
    @Published var isLoading = false
    @Published var errorMessage: Error?
    
    private var service: NetworkServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // Дефолтный город если нет локации
    private let defaultLat = 40.7128
    private let defaultLon = -74.0060
    
    init() {
        self.service = NetworkService()
    }
    
    func setService(_ service: NetworkServiceProtocol) {
        self.service = service
    }
    
    func loadWeather(lat: Double?, lon: Double?) {
        let lat = lat ?? defaultLat
        let lon = lon ?? defaultLon
        
        isLoading = true
        errorMessage = nil
        
        Publishers.Zip(
            service.fetchCurrentWeatherByCoord(lat: lat, lon: lon),
            service.fetchOneCall(lat: lat, lon: lon)
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            self?.isLoading = false
            if case .failure(let error) = completion {
                self?.errorMessage = error
            }
        } receiveValue: { [weak self] weather, oneCall in
            self?.currentWeather = weather
            self?.oneCall = oneCall
        }
        .store(in: &cancellables)
    }
    
    // Почасовой прогноз — первые 24 часа
    var hourlyForecast: [HourlyWeather] {
        Array(oneCall?.hourly?.prefix(24) ?? [])
    }
    
    var todayDayTemp: Double? { oneCall?.daily.first?.temp.day }
    var todayNightTemp: Double? { oneCall?.daily.first?.temp.min }
}
