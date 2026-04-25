//
//  AIConsultantProtocol.swift
//  WearlyWeather
//
//  Created by Anton Stremovskiy on 17.04.26.
//

/*protocol AIConsultant {
    func weatherSummary(for weather: ForecastItem, type: AISummaryType, city: String) async throws -> String
}*/

enum AIProvider: String, CaseIterable {
    case local = "local"
    case cloud = "cloud"
}

protocol AIConsultant {
    var isReady: Bool { get }
    func generateWeatherSummary(for weather: WeatherContext, type: AISummaryType, city: String, onUpdate: @escaping (String) -> Void) async throws
}
