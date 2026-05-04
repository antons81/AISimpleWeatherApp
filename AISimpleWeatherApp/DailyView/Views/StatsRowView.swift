
//  Untitled.swift
//  AISimpleWeatherApp
//
//  Created by Anton Stremovskiy on 13.04.26.
//

// StatsRowView.swift
// Humidity / Wind / Pressure cards
import SwiftUI

struct StatsRowView: View {

    let item: DailyWeather
    let currentWeather: CurrentWeather

    var body: some View {
        VStack {
            HStack {
                StatCard(
                    icon: "drop.fill",
                    iconColor: AppTheme.accentBlue,
                    value: "\(item.humidity ?? 0)%",
                    label: "Humidity"
                )
                StatCard(
                    icon: "wind",
                    iconColor: AppTheme.accentGreen,
                    value: ("\(item.windSpeed, default: "0") m/s"),
                    label: "Wind"
                )
                StatCard(
                    icon: "thermometer.medium",
                    iconColor: Color.orange.opacity(0.8),
                    value: "\(item.pressure ?? 0)",
                    label: "Pressure"
                )
            }
            HStack {
                StatCard(
                    icon: "sun.max.fill",
                    iconColor: item.uvi?.uviLevel.color ?? .orange,
                    value: "\(Int(item.uvi?.rounded() ?? 0))",
                    label: "\(item.uvi?.uviLevel.label ?? "UV Index")"
                )
                StatCard(
                    icon: "cloud.fill",
                    iconColor: Color(AppTheme.accentClouds).opacity(0.8),
                    value: "\(currentWeather.clouds?.all ?? 0)%",
                    label: "Clouds"
                )
                StatCard(
                    icon: "eye.fill",
                    iconColor: Color(AppTheme.accentVisibility).opacity(0.8),
                    value: (currentWeather.visibility ?? 0) >= 10000 ? "10+ km" : "\((currentWeather.visibility ?? 0) / 1000) km",
                    label: "Visibility"
                )
            }
        }
    }
}

struct StatCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(iconColor)
            Text(value)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
            Text(label)
                .font(.system(size: 10, design: .rounded))
                .foregroundStyle(AppTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .glassCard(cornerRadius: 14)
    }
}

extension Double {
    var uviLevel: (label: String, color: Color) {
        switch Int(self.rounded()) {
        case 0...2:  return ("Low", .green)
        case 3...5:  return ("Moderate", .yellow)
        case 6...7:  return ("High", .orange)
        case 8...10: return ("Very High", .red)
        default:     return ("Extreme", .purple)
        }
    }
}
