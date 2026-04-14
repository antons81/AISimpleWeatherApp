//
//  AISimpleWeatherAppTests.swift
//  AISimpleWeatherAppTests
//
//  Created by Anton Stremovskiy on 14.04.26.
//

import Testing
import Foundation
import XCTest
@testable import WearlyWeather


final class CurrentWeatherModelTests: XCTestCase {
    
    func test_decoding_validJSON() throws {
        let json = """
            {
                "name": "Berlin",
                "coord": { "lat": 52.52, "lon": 13.405 },
                "weather": [{ "id": 800, "main": "Clear", "description": "clear sky", "icon": "01d" }],
                "main": { "temp": 289.15, "feels_like": 287.0, "temp_min": 287.0, "temp_max": 291.0, "pressure": 1013, "humidity": 45 },
                "wind": { "speed": 3.5 },
                "sys": { "country": "DE", "sunrise": 1700000000, "sunset": 1700040000 }
            }
            """.data(using: .utf8)!
        
        let weather = try JSONDecoder().decode(CurrentWeather.self, from: json)
        
        XCTAssertEqual(weather.name, "Berlin")
        XCTAssertEqual(weather.coord?.lat, 52.52)
        XCTAssertEqual(weather.weather?.first?.icon, "01d")
        XCTAssertEqual(weather.main?.humidity, 45)
        XCTAssertEqual(weather.wind?.speed, 3.5)
    }
    
    func test_decoding_missingFields_doesNotCrash() throws {
        // Минимальный JSON — проверяем что опциональные поля не крашат
        let json = """
            { "name": "Berlin" }
            """.data(using: .utf8)!
        
        let weather = try JSONDecoder().decode(CurrentWeather.self, from: json)
        XCTAssertEqual(weather.name, "Berlin")
        XCTAssertNil(weather.coord)
        XCTAssertNil(weather.main)
    }
}

