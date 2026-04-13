
//  Untitled.swift
//  AISimpleWeatherApp
//
//  Created by Anton Stremovskiy on 13.04.26.
//

// StatsRowView.swift
// Humidity / Wind / Pressure cards
import SwiftUI

struct StatsRowView: View {

    let item: ForecastItem

    var body: some View {
        HStack(spacing: 8) {
            StatCard(
                icon: "drop.fill",
                iconColor: AppTheme.accentBlue,
                value: "\(item.main?.humidity ?? 0)%",
                label: "Humidity"
            )
            StatCard(
                icon: "wind",
                iconColor: AppTheme.accentGreen,
                value: item.wind?.speed.map { "\(Int($0)) m/s" } ?? "--",
                label: "Wind"
            )
            StatCard(
                icon: "thermometer.medium",
                iconColor: Color.orange.opacity(0.8),
                value: "\(item.main?.pressure ?? 0)",
                label: "Pressure"
            )
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
