//
//  GeocodingResult.swift
//  WearlyWeather
//
//  Created by Anton Stremovskiy on 04.05.26.
//
import SwiftUI

struct GeocodingResult: Decodable, Identifiable {
    var id: String { "\(lat),\(lon)" }
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?
    let localNames: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case name, lat, lon, country, state
        case localNames = "local_names"
    }
    
    // Берём локализованное имя
    var localizedName: String {
        let langCode = Locale.current.language.languageCode?.identifier ?? "en"
        return localNames?[langCode] ?? localNames?["en"] ?? name
    }
}
