
import SwiftUI

struct DailyHeaderView: View {

    let item: DailyWeather
    let cityName: String
    let dayTemp: Double?
    let nightTemp: Double?

    @AppStorage("isImperial") private var isImperial = false

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            WeatherIconView(iconCode: item.weather.first?.icon ?? "01d", size: 88)
                .frame(width: 100, height: 100)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Color.white.opacity(0.18), lineWidth: 0.5)
                        )
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(cityName)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(dayString)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)

                Text(description)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary.opacity(0.8))

                HStack(spacing: 8) {
                       Label(nightTempString, systemImage: "moon.fill")
                           .font(.system(size: 14, weight: .medium, design: .rounded))
                           .foregroundStyle(AppTheme.accentBlue)
                       Text("/")
                           .foregroundStyle(AppTheme.textTertiary)
                       Label(dayTempString, systemImage: "sun.max.fill")
                           .font(.system(size: 14, weight: .medium, design: .rounded))
                           .foregroundStyle(AppTheme.accentGreen)
                   }
            }

            Spacer()
        }
        .padding(16)
        .glassCard()
    }

    private var dayString: String {
        Date(timeIntervalSince1970: TimeInterval(item.dt))
            .formatted(.dateTime.weekday(.wide))
            .localizedCapitalized
    }

    private var description: String {
        item.weather.first?.weatherDescription?.capitalizingFirstLetter() ?? ""
    }

    private var dayTempString: String {
        guard let temp = dayTemp else { return "--" }
        return isImperial ? temp.toFahrenheitString : temp.toCelsiusString
    }
    
    private var nightTempString: String {
        guard let temp = nightTemp else { return "--" }
        return isImperial ? temp.toFahrenheitString : temp.toCelsiusString
    }
}
