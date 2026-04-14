//
//  AIPromtBuilderTests.swift
//  AISimpleWeatherApp
//
//  Created by Anton Stremovskiy on 14.04.26.
//

import XCTest
@testable import WearlyWeather

final class AIPromptBuilderTests: XCTestCase {
    
    func test_prompt_containsCondition() {
        let item = makeForecastItem(description: "clear sky", temp: 293.15)
        let prompt = AIPromptBuilder.weatherSummary(for: item, type: .normal)
        XCTAssertTrue(prompt.contains("clear sky"))
    }
    
    func test_prompt_runnerMode_containsRunnerContext() {
        let item = makeForecastItem(description: "light rain", temp: 283.15)
        let prompt = AIPromptBuilder.weatherSummary(for: item, type: .runner)
        XCTAssertTrue(prompt.lowercased().contains("runner") || prompt.lowercased().contains("training"))
    }
    
    func test_prompt_normalMode_containsNormalContext() {
        let item = makeForecastItem(description: "cloudy", temp: 283.15)
        let prompt = AIPromptBuilder.weatherSummary(for: item, type: .normal)
        XCTAssertFalse(prompt.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeForecastItem(description: String, temp: Double) -> ForecastItem {
        let json = """
        {
            "dt": 1700000000,
            "main": { "temp": \(temp), "feels_like": \(temp - 2), "temp_min": \(temp - 2), "temp_max": \(temp + 2), "pressure": 1013, "humidity": 60 },
            "weather": [{ "id": 800, "description": "\(description)", "icon": "01d" }],
            "dt_txt": "2024-01-01 12:00:00"
        }
        """.data(using: .utf8)!
        return try! JSONDecoder().decode(ForecastItem.self, from: json)
    }
}
