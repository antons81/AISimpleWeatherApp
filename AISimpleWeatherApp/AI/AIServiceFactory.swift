//
//  AIServiceFactory.swift
//  WearlyWeather
//
//  Created by Anton Stremovskiy on 17.04.26.
//

final class AIServiceFactory {
    static func create(isOffline: Bool) -> AIConsultant {
        if isOffline {
            return LocalAIService.shared
        } else {
            return CloudGeminiService()
        }
    }
}
