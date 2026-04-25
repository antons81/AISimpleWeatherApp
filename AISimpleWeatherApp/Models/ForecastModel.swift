// ForecastModel.swift
// Data model for OpenWeatherMap /data/2.5/forecast response

import Foundation

// MARK: - ForecastResponse (top-level wrapper with "list" key)

struct ForecastResponse: Codable {
    let list: [ForecastItem]
}


// MARK: - ForecastItem (one 3-hour slot)

struct ForecastItem: Codable, Identifiable {
    // Synthetic id based on timestamp
    var id: Int64 { dt ?? 0 }

    let dt: Int64?
    let main: ForecastMain?
    let weather: [ForecastWeather]?
    let dtTxt: String?
    let wind: ForecastWind?

    enum CodingKeys: String, CodingKey {
        case dt, main, weather, wind
        case dtTxt = "dt_txt"
    }
}

// MARK: - ForecastMain

struct ForecastMain: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let seaLevel: Int?
    let grndLevel: Int?
    let humidity: Int
    let tempKf: Double?

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin   = "temp_min"
        case tempMax   = "temp_max"
        case pressure
        case seaLevel  = "sea_level"
        case grndLevel = "grnd_level"
        case humidity
        case tempKf    = "temp_kf"
    }
}

// MARK: - ForecastWeather

struct ForecastWeather: Codable {
    let id: Int
    let weatherDescription: String?
    let icon: String?

    enum CodingKeys: String, CodingKey {
        case id
        case weatherDescription = "description"
        case icon
    }
}

struct ForecastWind: Codable {
    let speed: Double?
    let deg: Int?
}

