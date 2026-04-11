//
//  WeatherIconView.swift
//  AISimpleWeatherApp
//
//  Created by Anton Stremovskiy on 11.04.26.
//

import SwiftUI

struct ForecastRowView: View {

    let item: ForecastItem

    @AppStorage("isImperial") private var isImperial: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            WeatherIconView(iconCode: item.weather?.first?.icon ?? "01d")

            Text(dayString)
                .font(.subheadline)
                .frame(minWidth: 80, alignment: .leading)

            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(maxTempString)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color(.orange))
                Text(minTempString)
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
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
                .frame(width: 36, height: 36)
        } else {
            Image(systemName: "cloud")
                .frame(width: 36, height: 36)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Helpers

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
