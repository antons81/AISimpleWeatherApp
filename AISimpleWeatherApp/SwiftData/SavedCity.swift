//
//  SavedCity.swift
//  WearlyWeather
//
//  Created by Anton Stremovskiy on 04.05.26.
//

// SavedCity.swift
import SwiftData
import Foundation

@Model
final class SavedCity {
    var id: UUID
    var name: String
    var lat: Double
    var lon: Double
    var country: String
    var addedAt: Date
    
    init(name: String, lat: Double, lon: Double, country: String) {
        self.id = UUID()
        self.name = name
        self.lat = lat
        self.lon = lon
        self.country = country
        self.addedAt = Date()
    }
}
