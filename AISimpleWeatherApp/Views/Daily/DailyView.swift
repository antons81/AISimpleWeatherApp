// DailyView.swift
// SwiftUI replacement for DailyWeatherViewController + DailyWeatherViewController.xib.
// Shows a header with the currently selected day and a list of upcoming days.

import SwiftUI

struct DailyView: View {

    let cityName: String
    let lat:      Double
    let lon:      Double

    @StateObject private var viewModel = DailyViewModel()

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if let selected = viewModel.selectedDay {
                    DailyHeaderView(item: selected, cityName: cityName)
                        .padding()
                }

                Divider()

                List(viewModel.forecastDays) { item in
                    ForecastRowView(item: item)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .contentShape(Rectangle())
                        .onTapGesture { viewModel.selectedDay = item }
                }
                .listStyle(.plain)
            }

            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.15))
            }
        }
        .navigationTitle(cityName)
        .navigationBarTitleDisplayMode(.inline)
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
            viewModel.loadForecast(lat: lat, lon: lon)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DailyView(cityName: "Berlin", lat: 52.52, lon: 13.405)
    }
}
