//
//  CloudAIService.swift
//  WearlyWeather
//
//  Created by Anton Stremovskiy on 17.04.26.
//

import FirebaseAI
import Foundation

final class CloudGeminiService: AIConsultant {
    
    var isReady: Bool { return true }
    
    private let model = FirebaseAI.firebaseAI().generativeModel(
        modelName: "gemini-2.5-flash",
        generationConfig: GenerationConfig (
            temperature: 0.8,
            topP: 0.95,
            topK: 40,
            maxOutputTokens: 2048,
            stopSequences: []
        )
    )
    
    private  func currentLanguage() -> String {
        let code = Locale.preferredLanguages.first ?? "en"
        // Convert "ru-DE" → "Russian", "de-DE" → "German" etc.
        let locale = Locale(identifier: code)
        return locale.localizedString(forLanguageCode: Locale.current.language.languageCode?.identifier ?? "en") ?? "English"
    }
    
    func generateWeatherSummary(for weather: WeatherContext, type: AISummaryType, city: String, onUpdate: @escaping (String) -> Void) async throws {
        let prompt = AIPromptBuilder.weatherSummary(for: weather, type: type, city: city)
        do {
            let response = try await model.generateContent(prompt)
            if let text = response.text {
                await MainActor.run { onUpdate(text) }
            }
        } catch {
            throw error
        }
    }
}

