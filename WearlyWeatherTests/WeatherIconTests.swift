//
//  WeatherIconTests.swift
//  AISimpleWeatherApp
//
//  Created by Anton Stremovskiy on 14.04.26.
//
import XCTest
@testable import WearlyWeather

final class WeatherIconServiceTests: XCTestCase {
    
    // Фиксированный sunrise/sunset — дневное время
    private let daySunrise: Int64 = 1700000000   // 00:00 UTC
    private let daySunset: Int64  = 1800000000   // давно прошёл закат
    
    func test_clearSky_day() {
        // conditionId 800 = clear sky
        // Используем будущий закат чтобы симулировать день
        let farFuture: Int64 = 9999999999
        let icon = WeatherIconService.iconName(conditionId: 800, sunrise: 0, sunset: farFuture)
        XCTAssertEqual(icon, "01d")
    }
    
    func test_clearSky_night() {
        // закат уже прошёл
        let icon = WeatherIconService.iconName(conditionId: 800, sunrise: 0, sunset: 1)
        XCTAssertEqual(icon, "01n")
    }
    
    func test_thunderstorm_prefix() {
        let icon = WeatherIconService.iconName(conditionId: 200, sunrise: 0, sunset: 9999999999)
        XCTAssertTrue(icon.hasPrefix("11"))
    }
    
    func test_snow_prefix() {
        let icon = WeatherIconService.iconName(conditionId: 601, sunrise: 0, sunset: 9999999999)
        XCTAssertTrue(icon.hasPrefix("13"))
    }
    
    func test_fog_prefix() {
        let icon = WeatherIconService.iconName(conditionId: 741, sunrise: 0, sunset: 9999999999)
        XCTAssertTrue(icon.hasPrefix("50"))
    }
    
    func test_allConditions_returnValidIcon() {
        // Проверяем что ни один conditionId не возвращает пустую строку
        let testIds = [200, 300, 500, 511, 520, 600, 700, 800, 801, 802, 803, 804]
        for id in testIds {
            let icon = WeatherIconService.iconName(conditionId: id, sunrise: 0, sunset: 9999999999)
            XCTAssertFalse(icon.isEmpty, "Empty icon for conditionId \(id)")
        }
    }
}
