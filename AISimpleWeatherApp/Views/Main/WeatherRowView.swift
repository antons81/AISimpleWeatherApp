// WeatherRowView.swift
// SwiftUI row for the main city list.
// Replaces WeatherCell.xib + WeatherCell.swift (setupCell method).

import SwiftUI

struct WeatherRowView: View {

    let weather:    CurrentWeather
    let isImperial: Bool

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            weatherIcon
            cityInfo
            Spacer()
            temperatureRange
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        )
    }

    // MARK: - Subviews

    @ViewBuilder
    private var weatherIcon: some View {
        let imageName = resolvedIconName

        if let uiImage = UIImage(named: imageName) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
        } else {
            Image(systemName: "cloud")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .foregroundStyle(.secondary)
        }
    }

    private var cityInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(weather.name?.localizedCapitalized ?? "")
                .font(.headline)
            Text(weather.weather?.first?.weatherDescription.capitalizingFirstLetter() ?? "")
                .font(.caption)
                .foregroundStyle(.secondary)
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
