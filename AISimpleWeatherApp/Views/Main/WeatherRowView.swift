//
//  WeatherIconView.swift
//  AISimpleWeatherApp
//
//  Created by Anton Stremovskiy on 11.04.26.
//

import SwiftUI


import SwiftUI

struct WeatherRowView: View {

    let weather: CurrentWeather
    let isImperial: Bool


    var body: some View {
        HStack(spacing: 14) {
            // Icon
            WeatherIconView(iconCode: weather.weather?.first?.icon ?? "01d", size: 44) // свой размер
                .frame(width: 52, height: 52) // свой размер
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Color.white.opacity(0.18), lineWidth: 0.5)
                        )
                )

            // City + description
            VStack(alignment: .leading, spacing: 3) {
                Text(weather.name?.localizedCapitalized ?? "")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(weather.weather?.first?.weatherDescription.capitalizingFirstLetter() ?? "")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            // Temperatures
            VStack(alignment: .trailing, spacing: 3) {
                Text(maxTemp)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.accentGreen)
                Text(minTemp)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppTheme.textTertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassCard()
    }

    private var minTemp: String {
        guard let temp = weather.main?.tempMin else { return "--" }
        return isImperial ? temp.toFahrenheitString : temp.toCelsiusString
    }

    private var maxTemp: String {
        guard let temp = weather.main?.tempMax else { return "--" }
        return isImperial ? temp.toFahrenheitString : temp.toCelsiusString
    }
}

