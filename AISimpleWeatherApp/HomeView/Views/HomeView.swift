//
//  HomeView.swift
//  WearlyWeather
//
//  Created by Anton Stremovskiy on 04.05.26.
//

// HomeView.swift
import SwiftUI
import CoreLocation

struct HomeView: View {
    
    @Binding var drawerOpen: Bool
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var networkService: NetworkService
    @StateObject private var viewModel = HomeViewModel()
    @AppStorage("isImperial") private var isImperial = false
    @Binding var selectedWeather: CurrentWeather?
    @Binding var selectedCityName: String
    
    private var activeWeather: CurrentWeather? {
        selectedWeather ?? viewModel.currentWeather
    }
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            WeatherAnimationView(iconCode: viewModel.currentWeather?.weather?.first?.icon ?? "01d")
            
            // Декоративные блобы
            Circle()
                .fill(Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.08))
                .frame(width: 300, height: 300)
                .offset(x: 120, y: -200)
                .blur(radius: 40)
            
            Circle()
                .fill(Color(red: 0.2, green: 0.5, blue: 0.3).opacity(0.06))
                .frame(width: 250, height: 250)
                .offset(x: -100, y: 300)
                .blur(radius: 40)
            
            VStack(spacing: 0) {
                // Nav bar
                navBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .tint(AppTheme.accentGreen)
                        .scaleEffect(1.4)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Главная температура
                            mainTempView
                                .padding(.top, 20)
                            
                            // День / Ночь
                            dayNightView
                            Spacer()
                            // Почасовой прогноз
                            hourlyView
                            
                            if let weather = activeWeather ?? viewModel.currentWeather {
                                NavigationLink {
                                    DailyView(
                                        cityName: selectedCityName.isEmpty ? locationManager.cityName : selectedCityName,
                                        lat: weather.coord?.lat ?? 40.7,
                                        lon: weather.coord?.lon ?? -74.0,
                                        currentWeather: weather
                                    )
                                } label: {
                                    HStack(spacing: 8) {
                                        Text("See 7-day forecast")
                                            .font(.system(size: 15, weight: .medium, design: .rounded))
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 13, weight: .medium))
                                    }
                                    .foregroundStyle(AppTheme.accentGreen)
                                    .padding(.vertical, 14)
                                    .frame(maxWidth: .infinity)
                                    .glassCard(cornerRadius: 16)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }

        .task {
            viewModel.setService(networkService)
            locationManager.requestLocation()
        }
        .onChange(of: locationManager.location) { _, location in
            guard let location else { return }
            viewModel.loadWeather(
                lat: location.coordinate.latitude,
                lon: location.coordinate.longitude
            )
        }
        .onChange(of: selectedWeather) { _, weather in
            guard let weather else { return }
            // One Call для day/night и hourly выбранного города
            if let lat = weather.coord?.lat, let lon = weather.coord?.lon {
                viewModel.loadWeather(lat: lat, lon: lon)
            }
        }
    }
    
    // MARK: - Nav bar
    
    private var navBar: some View {
        HStack {
            Button {
                withAnimation(.spring(response: 0.35)) { drawerOpen = true }
            } label: {
                ZStack {
                    Circle().fill(Color.white.opacity(0.1)).frame(width: 38, height: 38)
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(AppTheme.textPrimary.opacity(0.8))
                }
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text(selectedWeather?.name ?? locationManager.cityName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                
                HStack(spacing: 4) {
                    Image(systemName: selectedWeather == nil ? "location.fill" : "mappin.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(AppTheme.accentGreen)
                    Text(selectedCityName.isEmpty ? locationManager.cityName : selectedCityName)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            
            Spacer()
            
            Circle().fill(Color.clear).frame(width: 38, height: 38)
//
//            // to daily view
//            if let weather = activeWeather ?? viewModel.currentWeather {
//                NavigationLink {
//                    DailyView(
//                        cityName: selectedWeather?.name ?? locationManager.cityName,
//                        lat: weather.coord?.lat ?? 0,
//                        lon: weather.coord?.lon ?? 0,
//                        currentWeather: weather
//                    )
//                } label: {
//                    ZStack {
//                        Circle().fill(Color.white.opacity(0.1)).frame(width: 38, height: 38)
//                        Image(systemName: "list.bullet")
//                            .font(.system(size: 16, weight: .regular))
//                            .foregroundStyle(AppTheme.textPrimary.opacity(0.8))
//                    }
//                }
//            } else {
//                Circle().fill(Color.clear).frame(width: 38, height: 38)
//            }
        }
    }
    
    // MARK: - Main temp
    
    private var mainTempView: some View {
        VStack(spacing: 12) {
            if let weather = activeWeather {
                WeatherIconView(iconCode: weather.weather?.first?.icon ?? "01d", size: 150)
                
                Text(isImperial
                     ? (weather.main?.temp.toFahrenheitString ?? "--")
                     : (weather.main?.temp.toCelsiusString ?? "--"))
                    .font(.system(size: 72, weight: .thin, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                
                Text(weather.weather?.first?.weatherDescription.capitalizingFirstLetter() ?? "")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
    }
    
    // MARK: - Day / Night
    
    private var dayNightView: some View {
        HStack(spacing: 24) {
            if let day = viewModel.todayDayTemp {
                Label(isImperial ? day.toFahrenheitString : day.toCelsiusString,
                      systemImage: "sun.max.fill")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.accentGreen)
            }
            
            if let night = viewModel.todayNightTemp {
                Label(isImperial ? night.toFahrenheitString : night.toCelsiusString,
                      systemImage: "moon.fill")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.accentBlue)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 24)
        .glassCard(cornerRadius: 20)
    }
    
    // MARK: - Hourly
    
    private var hourlyView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hourly forecast")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .padding(.horizontal, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.hourlyForecast) { item in
                        hourlyItem(item)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(16)
        .glassCard()
    }
    
    private func hourlyItem(_ item: HourlyWeather) -> some View {
        VStack(spacing: 6) {
            Text(hourTime(item.dt))
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(AppTheme.textTertiary)
            
            WeatherIconView(iconCode: item.weather.first?.icon ?? "01d", size: 24)
                .frame(width: 28, height: 28)
            
            Text(isImperial ? item.temp.toFahrenheitString : item.temp.toCelsiusString)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
    }
    
    private func hourTime(_ dt: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(dt))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
}
