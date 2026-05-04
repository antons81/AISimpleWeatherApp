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
        HStack(spacing: 12) {
            // Icon
            WeatherIconView(iconCode: weather.weather?.first?.icon ?? "01d", size: 44)
                .frame(width: 52, height: 52)
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
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(weather.weather?.first?.weatherDescription.capitalizingFirstLetter() ?? "")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            // Temperatures
            VStack(alignment: .trailing, spacing: 3) {
                HStack(spacing: 3) {
                    
                    CustomText(text: "Now:", size: 12, design: .rounded, color: AppTheme.textTertiary)
                    
                    CustomText(text: mainTemp, size: 16, weight: .medium, design: .rounded, color: AppTheme.accentGreen)
                }
                HStack {
                    Text("Feels:")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(AppTheme.textTertiary)
                    Text(feelsLike)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppTheme.textTertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassCard()
        .onAppear {
//            print("city: \(weather.name ?? "empty") min temp: \(minTemp), maxTemp: \(maxTemp)")
//            print("kelvin min: \(weather.main?.temp, default: "")")
//            print("to celcius min: \(weather.main?.temp.toCelsiusString ?? "")")
//            print("kelvin max: \(weather.main?.temp, default: "")")
//            print("to celcius max: \(weather.main?.temp.toCelsiusString ?? "")")
        }
    }
    
    private var mainTemp: String {
        guard let temp = weather.main?.temp else { return "--" }
        return isImperial ? temp.toFahrenheitString : temp.toCelsiusString
    }

    private var feelsLike: String {
        guard let temp = weather.main?.feelsLike else { return "--" }
        return isImperial ? temp.toFahrenheitString : temp.toCelsiusString
    }
}

