// ForecastRowView.swift
// Row shown in the daily forecast list inside DailyView.
// Replaces WeatherCell.setupCurrentWeather(_:isImperial:) from the old code.

import SwiftUI

struct ForecastRowView: View {

    let item: ForecastItem

    @AppStorage("isImperial") private var isImperial: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            weatherIcon

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
                Text(minTempString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemBackground))
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
