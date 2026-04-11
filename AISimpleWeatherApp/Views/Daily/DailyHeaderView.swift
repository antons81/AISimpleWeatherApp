// DailyHeaderView.swift
// Large weather summary card shown at the top of DailyView.
// Corresponds to the bigIcon / day / desc / min / max outlets in the old XIB.

import SwiftUI

struct DailyHeaderView: View {

    let item:     ForecastItem
    let cityName: String

    @AppStorage("isImperial") private var isImperial: Bool = false

    var body: some View {
        HStack(spacing: 20) {
            weatherIcon

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

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.08), radius: 6)
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
