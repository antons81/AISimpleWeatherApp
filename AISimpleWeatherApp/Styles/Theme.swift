//
//  Theme.swift
//  AISimpleWeatherApp
//
//  Created by Anton Stremovskiy on 12.04.26.
//

// AppTheme.swift
// Global design tokens for the green glassmorphism theme

import SwiftUI

enum AppTheme {

    // MARK: - Background gradient
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.10, green: 0.24, blue: 0.17),
            Color(red: 0.05, green: 0.14, blue: 0.09),
            Color(red: 0.03, green: 0.09, blue: 0.06)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Glass card
    static let glassBackground   = Color.white.opacity(0.08)
    static let glassBorder       = Color.white.opacity(0.15)
    static let glassRadius: CGFloat = 20

    // MARK: - Accent colors
    static let accentGreen  = Color(red: 0.47, green: 1.0, blue: 0.59)
    static let accentBlue   = Color(red: 0.47, green: 0.78, blue: 1.0)

    // MARK: - Text
    static let textPrimary   = Color.white
    static let textSecondary = Color.white.opacity(0.5)
    static let textTertiary  = Color.white.opacity(0.35)
}

// MARK: - Glass card modifier

struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = AppTheme.glassRadius

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(AppTheme.glassBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .strokeBorder(AppTheme.glassBorder, lineWidth: 0.5)
                    )
            )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = AppTheme.glassRadius) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius))
    }
}

// MARK: - Full screen background modifier

struct AppBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            content
        }
    }
}

extension View {
    func appBackground() -> some View {
        modifier(AppBackground())
    }
}
