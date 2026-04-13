//
//  WeatherIconView.swift
//  AISimpleWeatherApp
//
//  Created by Anton Stremovskiy on 11.04.26.
//

import SwiftUI

struct MainView: View {

    @StateObject private var viewModel = MainViewModel()
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.backgroundGradient
                .ignoresSafeArea()

            // Decorative blobs
            Circle()
                .fill(Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.08))
                .frame(width: 300, height: 300)
                .offset(x: 120, y: -200)
                .blur(radius: 40)

            Circle()
                .fill(Color(red: 0.2, green: 0.5, blue: 0.3).opacity(0.07))
                .frame(width: 250, height: 250)
                .offset(x: -100, y: 300)
                .blur(radius: 40)

            VStack(spacing: 0) {
                // Top bar
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                // Search
                searchBar
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                // City list
                if viewModel.filteredWeathers.isEmpty && !viewModel.isLoading {
                    Spacer()
                    ContentUnavailableView(
                        "No Cities",
                        systemImage: "cloud.slash",
                        description: Text("Pull to refresh or check your search.")
                    )
                    .foregroundStyle(AppTheme.textSecondary)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.filteredWeathers) { weather in
                                NavigationLink {
                                    DailyView(
                                        cityName: weather.name ?? "",
                                        lat: weather.coord?.lat ?? 0,
                                        lon: weather.coord?.lon ?? 0,
                                        currentWeather: weather
                                    )
                                } label: {
                                    WeatherRowView(
                                        weather: weather,
                                        isImperial: viewModel.isImperial
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                    .refreshable { viewModel.loadWeather() }
                }
            }

            // Loading overlay
            if viewModel.isLoading {
                Color.black.opacity(0.2).ignoresSafeArea()
                ProgressView()
                    .tint(AppTheme.accentGreen)
                    .scaleEffect(1.4)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .task { viewModel.loadWeather() }
        .alert(
            "Error",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            ),
            actions: { Button("OK", role: .cancel) {} },
            message: { Text(viewModel.errorMessage ?? "") }
        )
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("World Weather")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(viewModel.isImperial ? "Imperial" : "Metric")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            // Settings button
            Button { showSettings = true } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 38, height: 38)
                    Image(systemName: "gearshape")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(AppTheme.textPrimary.opacity(0.8))
                }
            }
        }
    }

    // MARK: - Search bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.textTertiary)

            TextField("", text: $viewModel.searchText)
                .placeholder(when: viewModel.searchText.isEmpty) {
                    Text("Search city...")
                        .foregroundStyle(AppTheme.textTertiary)
                        .font(.system(size: 14, design: .rounded))
                }
                .foregroundStyle(AppTheme.textPrimary)
                .font(.system(size: 14, design: .rounded))
                .autocorrectionDisabled()

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppTheme.textTertiary)
                        .font(.system(size: 14))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .glassCard(cornerRadius: 14)
    }
}

// MARK: - Placeholder helper

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: .leading) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}


// MARK: - Preview

#Preview {
    NavigationStack {
        MainView()
    }
}
