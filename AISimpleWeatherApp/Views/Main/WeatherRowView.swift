//
//  WeatherIconView.swift
//  AISimpleWeatherApp
//
//  Created by Anton Stremovskiy on 11.04.26.
//

import SwiftUI

struct WeatherRowView: View {
    
    let weather: CurrentWeather
    let isImperial: Bool

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            WeatherIconView(iconCode: weather.weather?.first?.icon ?? "01d")
            cityInfo
            Spacer()
            temperatureRange
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.80, green: 0.90, blue: 0.99).opacity(0.65),
                            Color(red: 0.62, green: 0.78, blue: 0.95).opacity(0.45)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                // Subtle inner highlight to lift the surface
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.28), lineWidth: 0.6)
                )
                // Ambient shadow (broad, soft)
                .shadow(color: Color.black.opacity(0.06), radius: 14, x: 0, y: 10)
                // Key light shadow (tighter, slightly colored)
                .shadow(color: Color(red: 0.50, green: 0.70, blue: 0.90).opacity(0.20), radius: 10, x: 0, y: 4)
                // Tiny contact shadow for depth
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 1)
        )
    }

    // MARK: - Subviews
    
    private var weatherIcon: some View {
        AsyncImage(url: iconURL) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            ProgressView()
        }
        .frame(width: 44, height: 44)
    }

    private var iconURL: URL? {
        guard let condition = weather.weather?.first else { return nil }
        let name = WeatherIconService.iconName(
            conditionId: condition.id,
            sunrise: weather.sys?.sunrise ?? 0,
            sunset:  weather.sys?.sunset  ?? 0
        )
        return URL(string: "https://openweathermap.org/img/wn/\(name)@2x.png")
    }

    private var cityInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(weather.name?.localizedCapitalized ?? "")
                .font(.headline)
            Text(weather.weather?.first?.weatherDescription.capitalizingFirstLetter() ?? "")
                .font(.caption)
                .foregroundColor(.black.opacity(0.8))
        }
    }

    private var temperatureRange: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(maxTempString)
                .font(.subheadline.bold())
            Text(minTempString)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Helpers

    private var resolvedIconName: String {
        guard let condition = weather.weather?.first else { return "01d" }
        return WeatherIconService.iconName(
            conditionId: condition.id,
            sunrise: weather.sys?.sunrise ?? 0,
            sunset:  weather.sys?.sunset  ?? 0
        )
    }

    private var minTempString: String {
        guard let temp = weather.main?.tempMin else { return "--" }
        return isImperial ? temp.toFahrenheitString : temp.toCelsiusString
    }

    private var maxTempString: String {
        guard let temp = weather.main?.tempMax else { return "--" }
        return isImperial ? temp.toFahrenheitString : temp.toCelsiusString
    }
}
