//
//  ExtensionsTests.swift
//  AISimpleWeatherApp
//
//  Created by Anton Stremovskiy on 14.04.26.
//

import XCTest
@testable import WearlyWeather

final class ExtensionsTests: XCTestCase {
    
    // MARK: - Temperature conversion
    
    func test_toCelsius_fromKelvin() {
        let kelvin: Double = 293.15
        XCTAssertEqual(kelvin.toCelsiusString, "20℃")
    }
    
    func test_toFahrenheit_fromKelvin() {
        let kelvin: Double = 293.15
        XCTAssertEqual(kelvin.toFahrenheitString, "68℉")
    }
    
    func test_absoluteZero_celsius() {
        let kelvin: Double = 0
        XCTAssertEqual(kelvin.toCelsiusString, "-273℃")
    }
    
    // MARK: - String
    
    func test_capitalizingFirstLetter() {
        XCTAssertEqual("hello world".capitalizingFirstLetter(), "Hello world")
    }
    
    func test_capitalizingFirstLetter_emptyString() {
        XCTAssertEqual("".capitalizingFirstLetter(), "")
    }
    
    func test_capitalizingFirstLetter_alreadyCapitalized() {
        XCTAssertEqual("Berlin".capitalizingFirstLetter(), "Berlin")
    }
    
    // MARK: - UserDefaults
    
    func test_isImperial_defaultsFalse() {
        UserDefaults.standard.removeObject(forKey: "isImperial")
        XCTAssertFalse(UserDefaults.isImperial)
    }
    
    func test_isImperial_persists() {
        UserDefaults.isImperial = true
        XCTAssertTrue(UserDefaults.isImperial)
        UserDefaults.isImperial = false // cleanup
    }
}
