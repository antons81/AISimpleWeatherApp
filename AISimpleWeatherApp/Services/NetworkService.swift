// NetworkService.swift
// Combine-based networking layer for OpenWeatherMap API.
// Replaces the old callback-based NetworkManager.

import Foundation
import Combine

// MARK: - API Endpoints

private enum Endpoint {
    case currentWeather(city: String)
    case forecast(lat: Double, lon: Double)

    private static let host   = "api.openweathermap.org"
    // ⚠️ Move this key to a .xcconfig / Info.plist before shipping to production
    private static let apiKey = "0cd74bf29e43ef1ad6afd6861cc99eb2"

    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host   = Endpoint.host

        switch self {
        case .currentWeather(let city):
            components.path = "/data/2.5/weather"
            components.queryItems = [
                URLQueryItem(name: "q",     value: city),
                URLQueryItem(name: "lang",  value: Locale.preferredLanguages.first ?? "en"),
                URLQueryItem(name: "appid", value: Endpoint.apiKey)
            ]

        case .forecast(let lat, let lon):
            components.path = "/data/2.5/forecast"
            components.queryItems = [
                URLQueryItem(name: "lat",   value: String(lat)),
                URLQueryItem(name: "lon",   value: String(lon)),
                URLQueryItem(name: "lang",  value: Locale.preferredLanguages.first ?? "en"),
                URLQueryItem(name: "appid", value: Endpoint.apiKey)
            ]
        }

        return components.url
    }
}

// MARK: - NetworkError

enum NetworkError: LocalizedError {
    case invalidURL
    case decodingFailed(Error)
    case underlying(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:            return "Invalid URL"
        case .decodingFailed(let e): return "Decoding failed: \(e.localizedDescription)"
        case .underlying(let e):     return e.localizedDescription
        }
    }
}

// MARK: - NetworkService

final class NetworkService: Sendable {

    static let shared = NetworkService()
    private init() {}

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .useDefaultKeys
        return d
    }()

    // MARK: Current weather for a single city name

    func fetchCurrentWeather(for city: String) -> AnyPublisher<CurrentWeather, NetworkError> {
        guard let url = Endpoint.currentWeather(city: city).url else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: CurrentWeather.self, decoder: decoder)
            .mapError { error in
                error is DecodingError
                    ? NetworkError.decodingFailed(error)
                    : NetworkError.underlying(error)
            }
            .eraseToAnyPublisher()
    }

    // MARK: 5-day / 3-hour forecast by coordinates

    func fetchForecast(lat: Double, lon: Double) -> AnyPublisher<[ForecastItem], NetworkError> {
        guard let url = Endpoint.forecast(lat: lat, lon: lon).url else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: ForecastResponse.self, decoder: decoder)
            .map(\.list)
            .mapError { error in
                error is DecodingError
                    ? NetworkError.decodingFailed(error)
                    : NetworkError.underlying(error)
            }
            .eraseToAnyPublisher()
    }
}
