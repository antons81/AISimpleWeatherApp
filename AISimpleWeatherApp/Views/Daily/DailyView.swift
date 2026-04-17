//
//  WeatherIconView.swift
//  AISimpleWeatherApp
//
//  Created by Anton Stremovskiy on 11.04.26.
//
// DailyView.swift
import SwiftUI

struct DailyView: View {

    let cityName: String
    let lat: Double
    let lon: Double
    let currentWeather: CurrentWeather

    @StateObject private var viewModel: DailyViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(cityName: String, lat: Double, lon: Double, currentWeather: CurrentWeather) {
        self.cityName = cityName
        self.lat = lat
        self.lon = lon
        self.currentWeather = currentWeather
        
        // service and viewmodel
        let cloudAI = CloudGeminiService()
        let vm = DailyViewModel(service: .shared, aiService: cloudAI)
        
        self._viewModel = StateObject(wrappedValue: vm)
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()

            // Decorative blobs
            Circle()
                .fill(Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.08))
                .frame(width: 280, height: 280)
                .offset(x: 130, y: -180)
                .blur(radius: 40)

            Circle()
                .fill(Color(red: 0.2, green: 0.5, blue: 0.3).opacity(0.06))
                .frame(width: 220, height: 220)
                .offset(x: -80, y: 280)
                .blur(radius: 40)

            VStack(spacing: 0) {
                // Nav bar
                navBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 16)

                ScrollView {
                    VStack(spacing: 10) {
                        // Header card
                        if let selected = viewModel.selectedDay {
                            DailyHeaderView(
                                item: selected,
                                cityName: cityName
                            )
                        }

                        // Stats row
                        if let selected = viewModel.selectedDay {
                            StatsRowView(item: selected)
                        }

                        // AI card
                        AIForecastCard(
                            weather: viewModel.selectedDay ?? viewModel.forecastDays.first,
                            viewModel: viewModel
                        )

                        // Forecast list
                        forecastList
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .onAppear {
                    UIScrollView.appearance().bounces = false
                    viewModel.cityName = cityName
                }
                .onDisappear {
                    UIScrollView.appearance().bounces = true
                }
            }

            if viewModel.isLoading {
                Color.black.opacity(0.15).ignoresSafeArea()
                ProgressView()
                    .tint(AppTheme.accentGreen)
                    .scaleEffect(1.4)
            }
        }
        .navigationBarHidden(true)
        .task {
            viewModel.loadForecast(lat: lat, lon: lon, type: .normal)
        }
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

    // MARK: - Nav bar

    private var navBar: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 36, height: 36)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.textPrimary.opacity(0.8))
                }
            }

            Text(cityName)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            Spacer()
        }
    }

    // MARK: - Forecast list

    private var forecastList: some View {
        VStack(spacing: 0) {
            ForEach(Array(viewModel.forecastDays.enumerated()), id: \.element.id) { index, item in
                ForecastRowView(item: item)
                    .contentShape(Rectangle())
                    .onTapGesture { viewModel.selectedDay = item }

                if index < viewModel.forecastDays.count - 1 {
                    Divider()
                        .background(Color.white.opacity(0.06))
                        .padding(.horizontal, 14)
                }
            }
        }
        .glassCard()
    }
}

// MARK: - Preview


//#Preview {
//    NavigationStack {
//        //DailyView(cityName: "Berlin", lat: 52.52, lon: 13.405)
//    }
//}
