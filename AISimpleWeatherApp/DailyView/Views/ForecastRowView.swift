// ForecastRowView.swift
import SwiftUI

struct ForecastRowView: View {

    let item: DailyWeather
    @AppStorage("isImperial") private var isImperial = false

    var body: some View {
        HStack(spacing: 12) {
            WeatherIconView(iconCode: item.weather.first?.icon ?? "01d", size: 44)
                .frame(width: 52, height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Color.white.opacity(0.18), lineWidth: 0.5)
                        )
                )

            Text(dayString)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
                .frame(minWidth: 80, alignment: .leading)

            Text(description)
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .lineLimit(1)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(dayTemp)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.accentGreen)
                Text(nightTemp)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
    }

    private var dayString: String {
        Date(timeIntervalSince1970: TimeInterval(item.dt))
            .formatted(.dateTime.weekday(.wide))
            .localizedCapitalized
    }

    private var description: String {
        item.weather.first?.weatherDescription?.capitalizingFirstLetter() ?? ""
    }

    private var dayTemp: String {
        isImperial ? item.temp.day.toFahrenheitString : item.temp.day.toCelsiusString
    }

    private var nightTemp: String {
        isImperial ? item.temp.min.toFahrenheitString : item.temp.min.toCelsiusString
    }
}
