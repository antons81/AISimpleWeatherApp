//
//  OneCallModel.swift
//  WearlyWeather
//
//  Created by Anton Stremovskiy on 25.04.26.
//


import Foundation


// MARK: - OneCallResponse

struct OneCallResponse: Decodable {
    let daily: [DailyWeather]
}

// MARK: - DailyWeather

struct DailyWeather: Decodable, Identifiable {
    var id: Int64 { dt }

    let dt: Int64
    let temp: DailyTemp
    let weather: [ForecastWeather]
    let humidity: Int?
    let windSpeed: Double?
    let pressure: Int?
    let uvi: Double?

    enum CodingKeys: String, CodingKey {
        case dt, temp, weather, humidity, uvi, pressure
        case windSpeed = "wind_speed"
    }
}

// MARK: - DailyTemp

struct DailyTemp: Decodable {
    let day: Double
    let night: Double
    let min: Double
    let max: Double
    let eve: Double?
    let morn: Double?
}


struct WeatherContext {
    let dt: Int64
    let dayTemp: Double
    let nightTemp: Double
    let description: String
    let humidity: Int?
    let windSpeed: Double?
    let icon: String
    let pressure: Int?
    
    // Из DailyWeather
    init(daily: DailyWeather) {
        self.dt          = daily.dt
        self.dayTemp     = daily.temp.day
        self.nightTemp   = daily.temp.night
        self.description = daily.weather.first?.weatherDescription ?? ""
        self.humidity    = daily.humidity
        self.windSpeed   = daily.windSpeed
        self.icon        = daily.weather.first?.icon ?? "01d"
        self.pressure    = daily.pressure
    }
    
    // Из ForecastItem (для обратной совместимости)
    init(forecast: ForecastItem) {
        self.dt          = forecast.dt ?? 0
        self.dayTemp     = forecast.main?.temp ?? 0
        self.nightTemp   = forecast.main?.tempMin ?? 0
        self.description = forecast.weather?.first?.weatherDescription ?? ""
        self.humidity    = forecast.main?.humidity
        self.windSpeed   = forecast.wind?.speed
        self.icon        = forecast.weather?.first?.icon ?? "01d"
        self.pressure    = forecast.main?.pressure
    }
}

