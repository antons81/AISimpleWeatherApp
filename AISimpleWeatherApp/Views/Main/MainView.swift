// MainView.swift
// SwiftUI replacement for MainViewController + MainViewController.xib.
// Shows a searchable list of cities with current weather.

import SwiftUI

struct MainView: View {

    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        ZStack {
            content

            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.15))
            }
        }
        .navigationTitle("World Weather App")
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
                systemImage: "cloud.slash",
                description: Text("Pull to refresh or check your search.")
            )
        } else {
            List(viewModel.filteredWeathers) { weather in
                NavigationLink {
                    DailyView(
                        cityName: weather.name ?? "",
                        lat: weather.coord?.lat ?? 0,
                        lon: weather.coord?.lon ?? 0
                    )
                } label: {
                    WeatherRowView(weather: weather, isImperial: viewModel.isImperial)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }
            .listStyle(.plain)
        }
    }

    // MARK: Metric / Imperial toggle in toolbar

    @ToolbarContentBuilder
    private var metricToggle: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 6) {
                Text(viewModel.isImperial ? "Imperial" : "Metric")
                    .font(.caption)
                Toggle("", isOn: Binding(
                    get: { viewModel.isImperial },
                    set: { viewModel.setImperial($0) }
                ))
                .toggleStyle(.switch)
                .labelsHidden()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MainView()
    }
}
