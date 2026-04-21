//
//  MockNetworkServices.swift
//  AISimpleWeatherApp
//
//  Created by Anton Stremovskiy on 14.04.26.
//

import Testing
import XCTest
import Combine
@testable import WearlyWeather

protocol NetworkServicing: Sendable {
    func fetchCurrentWeather(for city: String) -> AnyPublisher<CurrentWeather, NetworkError>
    func fetchForecast(lat: Double, lon: Double) -> AnyPublisher<[ForecastItem], NetworkError>
}

final class MockNetworkService: NetworkServicing {
    
    init() {
    }
    
    var mockWeather: CurrentWeather?
    var mockForecast: [ForecastItem] = []
    var shouldFail = false
    
    func fetchCurrentWeather(for city: String) -> AnyPublisher<CurrentWeather, NetworkError> {
        if shouldFail {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        guard let weather = mockWeather else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        return Just(weather)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
    
    func fetchForecast(lat: Double, lon: Double) -> AnyPublisher<[ForecastItem], NetworkError> {
        if shouldFail {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        return Just(mockForecast)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
}
