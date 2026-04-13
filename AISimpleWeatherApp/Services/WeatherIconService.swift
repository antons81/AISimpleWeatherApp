// WeatherIconService.swift
// Maps OpenWeatherMap weather condition ID + day/night flag to an asset image name.
// Preserves the same lookup logic as the original WeatherCell extension.

import Foundation

enum WeatherIconService {

    /// Returns the asset name (e.g. "01d", "10n") for a given OWM condition code.
    /// - Parameters:
    ///   - conditionId: OWM weather condition ID (e.g. 800 = clear sky)
    ///   - sunrise: Unix timestamp of sunrise
    ///   - sunset: Unix timestamp of sunset
    static func iconName(conditionId: Int, sunrise: Int64, sunset: Int64) -> String {
        let suffix = isNight(sunrise: sunrise, sunset: sunset) ? "n" : "d"
        let prefix = iconPrefix(for: conditionId)
        return prefix + suffix
    }

    // MARK: - Private helpers

    private static func isNight(sunrise: Int64, sunset: Int64) -> Bool {
        let now = Date().timeIntervalSince1970
        return now < TimeInterval(sunrise) || now > TimeInterval(sunset)
    }

    private static func iconPrefix(for id: Int) -> String {
        switch id {
        case ..<300:    return "11"   // Thunderstorm
        case ..<400:    return "09"   // Drizzle
        case 500...504: return "10"   // Rain
        case 511:       return "13"   // Freezing rain
        case ..<600:    return "09"   // Shower rain
        case ..<700:    return "13"   // Snow
        case ..<800:    return "50"   // Atmosphere (fog, mist…)
        case 800:       return "01"   // Clear sky
        case 801:       return "02"   // Few clouds
        case 802:       return "03"   // Scattered clouds
        case 803...804: return "04"   // Broken / overcast
        default:        return "01"
        }
    }
}
