// CurrentWeatherModel.swift
// Data model for OpenWeatherMap /data/2.5/weather response

import Foundation

// MARK: - CurrentWeather

struct CurrentWeather: Codable, Identifiable {
    // Synthetic id required by SwiftUI List / ForEach
    var id: String { name ?? UUID().uuidString }

    let coord: Coord?
    let weather: [Weather]?
    let main: WeatherMain?
    let sys: Sys?
    let name: String?
    let wind: Wind?

    enum CodingKeys: String, CodingKey {
        case coord, weather, main, sys, name, wind
    }
}

// MARK: - Coord

struct Coord: Codable {
    let lon: Double
    let lat: Double
}

// MARK: - Wind

struct Wind: Codable {
    let speed: Double
}

// MARK: - WeatherMain

struct WeatherMain: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin   = "temp_min"
        case tempMax   = "temp_max"
        case pressure
        case humidity
    }
}

// MARK: - Sys

struct Sys: Codable {
    let country: String?
    let sunrise: Int64?
    let sunset:  Int64?
}

// MARK: - Weather condition item

struct Weather: Codable {
    let id: Int
    let main: String
    let weatherDescription: String
    let icon: String

    enum CodingKeys: String, CodingKey {
        case id, main
        case weatherDescription = "description"
        case icon
    }
}
