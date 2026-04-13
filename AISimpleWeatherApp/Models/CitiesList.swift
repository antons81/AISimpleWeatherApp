// CitiesList.swift
// Static data source: list of cities for the main weather screen

import Foundation

enum City: String, CaseIterable {
    case wuppertal    = "Wuppertal"
    case berlin       = "Berlin"
    case telAviv      = "Tel Aviv"
    case newYork      = "New York"
    case brussels     = "Brussels"
    case barcelona    = "Barcelona"
    case paris        = "Paris"
    case tokyo        = "Tokyo"
    case beijing      = "Beijing"
    case sydney       = "Sydney"
    case buenosAires  = "Buenos Aires"
    case miami        = "Miami"
    case vancouver    = "Vancouver"
    case kyiv         = "Kyiv"
    case bangkok      = "Bangkok"
    case manila       = "Manila"

    /// All city name strings in one array
    static var allNames: [String] { allCases.map(\.rawValue) }
}
