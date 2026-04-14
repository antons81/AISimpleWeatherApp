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
    
    static func weatherSummary(for weather: ForecastItem, type: AISummaryType) -> String {
        //let city = weather.weatherDescription.rawValue ?? "this city"
        let desc = weather.weather?.first?.weatherDescription ?? ""
        let temp = weather.main?.temp.toCelsiusString ?? "--"
        let humidity = weather.main?.humidity ?? 0
        let feels = weather.main?.feelsLike.toCelsiusString ?? "--"
        let wind = weather.wind?.speed.map { "\(Int($0)) m/s" } ?? "--"
        
        return """
        
        You are a helpful assistant for a weather app.
        Mode: \(type.description).
        Language: \(currentLanguage()).

        Current weather:
        - Condition: \(desc)
        - Temperature: \(temp)
        - Humidity: \(humidity)%
        - Feels like: \(feels)
        - Wind: \(wind)
        - Time: \(Date().formattedTime) (\(Date().timeOfDayDescription))

        Instructions:
        1. Answer ONLY in \(currentLanguage()) language.
        2. Write 2-3 short sentences, plain text only, no markdown, no bullet points, no headers.
        3. Give a brief summary and one practical tip with light humor.
        
        """
    }
}
