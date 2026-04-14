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

final class MockNetworkService: NetworkService {
    
    var mockWeather: CurrentWeather?
    var mockForecast: [ForecastItem] = []
    var shouldFail = false
    
    override func fetchCurrentWeather(for city: String) -> AnyPublisher<CurrentWeather, NetworkError> {
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
    
    override func fetchForecast(lat: Double, lon: Double) -> AnyPublisher<[ForecastItem], NetworkError> {
        if shouldFail {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        return Just(mockForecast)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
}
