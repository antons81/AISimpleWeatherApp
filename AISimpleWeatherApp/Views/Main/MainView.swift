//
//  WeatherIconView.swift
//  AISimpleWeatherApp
//
//  Created by Anton Stremovskiy on 11.04.26.
//

import SwiftUI

struct MainView: View {

    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        ZStack {
            // App-wide subtle gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.92, green: 0.96, blue: 1.00),
                    Color(red: 0.86, green: 0.93, blue: 0.99)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            content

            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.15))
            }
        }
        .navigationTitle("World Weather AI")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { metricToggle }
        .searchable(
            text: $viewModel.searchText,
            prompt: Text("Search city…")
        )
        .alert(
            "Loading Error",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            ),
            actions: { Button("OK", role: .cancel) {} },
            message: { Text(viewModel.errorMessage ?? "") }
        )
        .task {
            // Initial data load when the view appears for the first time
            viewModel.loadWeather()
        }
        .refreshable {
            // Pull-to-refresh support
            viewModel.loadWeather()
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var content: some View {
        if viewModel.filteredWeathers.isEmpty && !viewModel.isLoading {
            ContentUnavailableView(
                "No Results",
                systemImage: "cloud",
                description: Text("Pull to refresh or check your search.")
            )
        } else {
            List(viewModel.filteredWeathers) { weather in
                ZStack {
                    WeatherRowView(weather: weather, isImperial: viewModel.isImperial)
                        .contentShape(Rectangle())
                    NavigationLink {
                        DailyView(
                            cityName: weather.name ?? "",
                            lat: weather.coord?.lat ?? 0,
                            lon: weather.coord?.lon ?? 0
                        )
                    } label: {
                        EmptyView()
                    }
                    .opacity(0.001) // invisible but tappable
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
        }
    }

    // MARK: Metric / Imperial toggle in toolbar

    @ToolbarContentBuilder
    private var metricToggle: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            UnitToggle(
                isImperial: viewModel.isImperial,
                onMetric: { viewModel.setImperial(false) },
                onImperial: { viewModel.setImperial(true) }
            )
        }
    }
}

// MARK: - Subviews (Private Helpers)

private struct UnitToggle: View {
    let isImperial: Bool
    let onMetric: () -> Void
    let onImperial: () -> Void

    var body: some View {
        let activeFill = Color.accentColor
        let inactiveFill = Color.clear
        let activeText: Color = .white
        let inactiveText: Color = .secondary

        HStack(spacing: 0) {
            Button(action: onMetric) {
                Text("Metric")
                    .font(.caption.weight(.semibold))
                    .padding(.vertical, 6)
                    .frame(width: 58)
                    .foregroundStyle(isImperial ? inactiveText : activeText)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(isImperial ? inactiveFill : activeFill)
                    )
            }
            .buttonStyle(.plain)

            Button(action: onImperial) {
                Text("Imperial")
                    .font(.caption.weight(.semibold))
                    .padding(.vertical, 6)
                    .frame(width: 68)
                    .foregroundStyle(isImperial ? activeText : inactiveText)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(isImperial ? activeFill : inactiveFill)
                    )
            }
            .buttonStyle(.plain)
        }
        .animation(.easeInOut(duration: 0.18), value: isImperial)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.35))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.white.opacity(0.45), lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MainView()
    }
}
