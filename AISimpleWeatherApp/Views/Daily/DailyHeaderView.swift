//
//  WeatherIconView.swift
//  AISimpleWeatherApp
//
//  Created by Anton Stremovskiy on 11.04.26.
//

import SwiftUI


struct DailyHeaderView: View {

    let item: ForecastItem
    let cityName: String

    @AppStorage("isImperial") private var isImperial: Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            WeatherIconView(iconCode: item.weather?.first?.icon ?? "01d")
            Spacer(minLength: 40)
            VStack(alignment: .leading, spacing: 4) {
                Text(cityName)
                    .font(.title2.bold())

                Text(dayString)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(description)
                    .font(.body)

                HStack(spacing: 8) {
                    Text(minTempString)
                        .font(.caption)
                        .foregroundStyle(.blue)
                    Text(maxTempString)
                        .font(.caption.bold())
                        .foregroundStyle(.orange)
                }
            }
            
            Spacer(minLength: 20)

        }
        .frame(width: .infinity)
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
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

    @ViewBuilder
    private var weatherIcon: some View {
        let name = item.weather?.first?.icon ?? "01d"
        if let uiImage = UIImage(named: name) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
        } else {
            Image(systemName: "cloud")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Computed strings

    private var dayString: String {
        guard let dt = item.dt else { return "" }
        return Date(timeIntervalSince1970: TimeInterval(dt))
            .formatted(.dateTime.weekday(.wide))
            .localizedCapitalized
    }

    private var description: String {
        item.weather?.first?.weatherDescription?.capitalizingFirstLetter() ?? ""
    }

    private var minTempString: String {
        guard let temp = item.main?.tempMin else { return "--" }
        return isImperial ? temp.toFahrenheitString : temp.toCelsiusString
    }

    private var maxTempString: String {
        guard let temp = item.main?.tempMax else { return "--" }
        return isImperial ? temp.toFahrenheitString : temp.toCelsiusString
    }
}

