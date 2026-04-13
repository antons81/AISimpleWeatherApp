//
//  Untitled.swift
//  AISimpleWeatherApp
//
//  Created by Anton Stremovskiy on 13.04.26.
//

// AIForecastCard.swift
import SwiftUI

struct AIForecastCard: View {

    let weather: ForecastItem?
    @ObservedObject var viewModel: DailyViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Header
            HStack {
                // Sparkles icon
                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.accentGreen)

                Text("AI Weather Tip")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)

                Spacer()

                // Refresh / loading
                if viewModel.aiService.isGenerating {
                    ProgressView()
                        .tint(AppTheme.accentGreen)
                        .scaleEffect(0.7)
                } else if !viewModel.aiSummary.isEmpty {
                    Button {
                        guard let item = weather else { return }
                        Task { await viewModel.generateAISummary(for: item, type: userType) }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 12))
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                }
            }

            // Content
            if viewModel.aiSummary.isEmpty && viewModel.aiService.isGenerating {
                // Показываем Thinking только пока текст ещё не начал появляться
                HStack(spacing: 8) {
                    ProgressView()
                        .tint(AppTheme.accentGreen)
                        .scaleEffect(0.8)
                    Text("Thinking...")
                        .font(.system(size: 13, weight: .light, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            } else if viewModel.aiSummary.isEmpty && !viewModel.aiService.isGenerating {
                // Кнопка Get Tip
                Button {
                    guard let item = weather else { return }
                    Task { await viewModel.generateAISummary(for: item, type: userType) }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12))
                        Text("Get AI weather advice")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                    }
                    .foregroundStyle(AppTheme.accentGreen)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(AppTheme.accentGreen.opacity(0.12))
                            .overlay(
                                Capsule()
                                    .strokeBorder(AppTheme.accentGreen.opacity(0.3), lineWidth: 0.5)
                            )
                    )
                }
            } else {
                // Текст появляется потоком — показываем сразу как только начался
                Text(viewModel.aiSummary)
                    .id(viewModel.aiSummary)
                    .font(.system(size: 13, weight: .light, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary.opacity(0.85))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .glassCard()
    }

    // Reads user type from Settings
    private var userType: AISummaryType {
        UserDefaults.standard.bool(forKey: "isRunner") ? .runner : .normal
    }
}
