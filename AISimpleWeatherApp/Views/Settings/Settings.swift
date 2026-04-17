//
//  Settings.swift
//  AISimpleWeatherApp
//
//  Created by Anton Stremovskiy on 13.04.26.
//

// SettingsView.swift
import SwiftUI

struct SettingsView: View {

    @AppStorage("isImperial") private var isImperial    = false
    @AppStorage("isRunner")   private var isRunner      = false
    @AppStorage("ai_provider")  private var provider: AIProvider = .local
    @Environment(\.dismiss)   private var dismiss
    
    private let localAIService = LocalAIService.shared
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()

            // Decorative blobs
            Circle()
                .fill(Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.08))
                .frame(width: 260, height: 260)
                .offset(x: 130, y: -160)
                .blur(radius: 40)

            VStack(spacing: 0) {
                // Nav
                HStack {
                    Text("Settings")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                    Button { dismiss() } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 32, height: 32)
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(AppTheme.textPrimary.opacity(0.7))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 24)

                ScrollView {
                    VStack(spacing: 12) {

                        // MARK: Preferences
                        sectionLabel("Preferences")

                        VStack(spacing: 0) {
                            settingsRow(
                                icon: "ruler",
                                iconColor: AppTheme.accentBlue,
                                title: "Units",
                                subtitle: isImperial ? "Imperial (°F)" : "Metric (°C)"
                            ) {
                                Toggle("", isOn: $isImperial)
                                    .tint(AppTheme.accentGreen)
                                    .labelsHidden()
                            }
                            
                            
                        }
                        .glassCard()
                        
                        VStack {
                            settingsRow(
                                icon: "sparkles",
                                iconColor: AppTheme.accentBlue,
                                title: "Use Gemini AI Model",
                                subtitle: provider == .cloud ? "Gemini (Cloud)" : "Llama (Local)"
                            ) {
                                Toggle("", isOn: Binding(
                                    get: { provider == .cloud },
                                    set: { isCloud in
                                        provider = isCloud ? .cloud : .local
                                        localAIService.releaseModel()
                                        // to local
                                        if !isCloud {
                                            Task {
                                                print("⚙️ Settings: Switching to Local, starting preload...")
                                                await localAIService.preloadModel()
                                            }
                                        }
                                    }
                                ))
                                .tint(AppTheme.accentGreen)
                                .labelsHidden()
                            }
                            
                        }
                        .glassCard()

                        // MARK: Profile
                        sectionLabel("Profile")

                        VStack(alignment: .leading, spacing: 12) {
                            Text("AI tips tailored for...")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundStyle(AppTheme.textSecondary)
                                .padding(.horizontal, 4)

                            HStack(spacing: 10) {
                                profileCard(
                                    icon: "figure.walk",
                                    title: "Regular",
                                    subtitle: "going outside",
                                    isSelected: !isRunner
                                ) { isRunner = false }

                                profileCard(
                                    icon: "figure.run",
                                    title: "Runner",
                                    subtitle: "training outside",
                                    isSelected: isRunner
                                ) { isRunner = true }
                            }
                        }
                        .padding(14)
                        .glassCard()

                        // MARK: AI Language
                        sectionLabel("AI Language")

                        VStack(spacing: 0) {
                            settingsRow(
                                icon: "globe",
                                iconColor: AppTheme.accentGreen,
                                title: "Auto detect",
                                subtitle: "Based on device language"
                            ) {
                                Text(currentLanguageName)
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundStyle(AppTheme.accentGreen.opacity(0.85))
                            }
                        }
                        .glassCard()

                        // MARK: App info
                        sectionLabel("About")

                        VStack(spacing: 0) {
                            settingsRow(
                                icon: "info.circle",
                                iconColor: AppTheme.textSecondary,
                                title: "Version",
                                subtitle: "Wearly Weather AI"
                            ) {
                                Text("1.0.0")
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundStyle(AppTheme.textTertiary)
                            }
                        }
                        .glassCard()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundStyle(AppTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
            .padding(.top, 4)
    }

    @ViewBuilder
    private func settingsRow<T: View>(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        @ViewBuilder trailing: () -> T
    ) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(subtitle)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()
            trailing()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func profileCard(
        icon: String,
        title: String,
        subtitle: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected
                            ? AppTheme.accentGreen.opacity(0.2)
                            : Color.white.opacity(0.06))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(isSelected
                            ? AppTheme.accentGreen
                            : AppTheme.textSecondary)
                }

                Text(title)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(isSelected ? AppTheme.textPrimary : AppTheme.textSecondary)

                Text(subtitle)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(AppTheme.textTertiary)

                Circle()
                    .fill(isSelected
                        ? AppTheme.accentGreen.opacity(0.8)
                        : Color.white.opacity(0.12))
                    .frame(width: 7, height: 7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected
                        ? AppTheme.accentGreen.opacity(0.08)
                        : Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                isSelected
                                    ? AppTheme.accentGreen.opacity(0.4)
                                    : Color.white.opacity(0.1),
                                lineWidth: isSelected ? 1 : 0.5
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var currentLanguageName: String {
        let code = Locale.preferredLanguages.first ?? "en"
        let locale = Locale(identifier: code)
        return locale.localizedString(
            forLanguageCode: Locale.current.language.languageCode?.identifier ?? "en"
        ) ?? "English"
    }
}

#Preview {
    SettingsView()
}
