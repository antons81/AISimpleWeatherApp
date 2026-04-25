//
//  AIPromptBuilder.swift
//  AISimpleWeatherApp
//
//  Created by Anton Stremovskiy on 12.04.26.
//

// AIPromptBuilder.swift
// Builds weather-specific prompts for the local LLM.

import Foundation

enum AISummaryType: CaseIterable {
    case normal
    case runner
    
    var description: String {
        switch self {
        case .normal: return "a regular person going outside"
        case .runner: return "a street runner or long distance runner — include what exactly to wear. Use all running gear, like a hood, gloves, etc."
        }
    }
}

enum AIPromptBuilder {
    
    static func currentLanguage() -> String {
        let code = Locale.preferredLanguages.first ?? "en"
        // Convert "ru-DE" → "Russian", "de-DE" → "German" etc.
        let locale = Locale(identifier: code)
        return locale.localizedString(forLanguageCode: Locale.current.language.languageCode?.identifier ?? "en") ?? "English"
    }
    
    static func isImperial() -> Bool {
        return UserDefaults.isImperial
    }
    
    static func weatherSummary(for weather: WeatherContext, type: AISummaryType, city: String) -> String {
        
        let unit = isImperial()
        let temp = unit ? weather.dayTemp.toFahrenheitString : weather.dayTemp.toCelsiusString
        let night = unit ? weather.nightTemp.toFahrenheitString : weather.nightTemp.toCelsiusString
        let wind = weather.windSpeed.map { "\(Int($0)) m/s" } ?? "--"
        let pressure = weather.pressure.map { "\($0) hPa" } ?? "--"
        
        return """
        You are a helpful assistant for a weather app.
        Mode: \(type.description).
        Language: \(currentLanguage()).

        Current weather:
        - City: \(city)
        - Condition: \(weather.description)
        - Day temperature: \(temp)
        - Night temperature: \(night)
        - Humidity: \(weather.humidity.map { "\($0)%" } ?? "--")
        - Pressure: \(pressure)
        - Wind: \(wind)
        - Time: \(Date().formattedTime) (\(Date().timeOfDayDescription))

        Instructions:
        1. Answer ONLY in \(currentLanguage()) language.
        2. Write 4-5 sentences.
        3. Use only plain text.
        4. Use bullet points only for lists of more than 3 items, otherwise, use descriptive paragraphs.
        5. Give a brief summary and one practical tip with light humor.
        """
    }
}
