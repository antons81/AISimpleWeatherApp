//
//  GeocodingViewRow.swift
//  WearlyWeather
//
//  Created by Anton Stremovskiy on 04.05.26.
//

import SwiftUI

struct GeocodingRowView: View {
    let result: GeocodingResult
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(AppTheme.accentGreen)

            VStack(alignment: .leading, spacing: 3) {
                Text(result.localizedName)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                Text([result.state, result.country].compactMap { $0 }.joined(separator: ", "))
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            Button(action: onAdd) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(AppTheme.accentGreen)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassCard()
    }
}
