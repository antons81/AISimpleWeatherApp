//
//  WeatherIconView.swift
//  AISimpleWeatherApp
//
//  Created by Anton Stremovskiy on 11.04.26.
//

import SwiftUI
import SwiftData

struct DrawerView: View {
    @EnvironmentObject private var networkService: NetworkService
    @StateObject private var viewModel = DrawerViewModel()
    @State private var showSettings = false
    @Binding var drawerOpen: Bool
    @Binding var selectedWeather: CurrentWeather?
    @Binding var selectedCityName: String
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedCity.addedAt) var savedCities: [SavedCity]
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                closeMenuButton
                topBar.padding(.horizontal, 20).padding(.top, 8)
                searchBar.padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 8)

                if viewModel.isSearchMode {
                    searchResultsList
                } else {
                    savedCitiesList
                }
            }

            if viewModel.isLoading {
                Color.black.opacity(0.2).ignoresSafeArea()
                ProgressView().tint(AppTheme.accentGreen).scaleEffect(1.4)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showSettings) { SettingsView() }
        .task {
            viewModel.setService(networkService)
            viewModel.loadWeather(for: savedCities)
        }
        .onChange(of: savedCities) { _, cities in
            viewModel.loadWeather(for: cities)
            print("💾 savedCities: \(savedCities.map { $0.name })")
            print("🌐 weathers: \(viewModel.weathers.map { $0.name })")
        }
        .alert("", isPresented: Binding(value: $viewModel.errorMessage), actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(viewModel.errorMessage?.localizedDescription ?? "")
        })
    }

    // MARK: - Top bar
    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Wearly Weather")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(viewModel.isImperial ? "Imperial" : "Metric")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            Spacer()
        }
    }
    
    // MARK: - Close button
    private var closeMenuButton: some View {
        HStack {
            Button {
                withAnimation(.spring(response: 0.35)) { drawerOpen = false }
            } label: {
                ZStack {
                    Circle().fill(Color.white.opacity(0.1)).frame(width: 38, height: 38)
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.textPrimary.opacity(0.8))
                }
            }
            Spacer()
            Button { showSettings = true } label: {
                ZStack {
                    Circle().fill(Color.white.opacity(0.1)).frame(width: 38, height: 38)
                    Image(systemName: "gearshape")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(AppTheme.textPrimary.opacity(0.8))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
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

    // MARK: - Search results
    private var searchResultsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 10) {
                if viewModel.isSearching {
                    ProgressView().tint(AppTheme.accentGreen).padding()
                } else if viewModel.searchResults.isEmpty {
                    Text("No results")
                        .foregroundStyle(AppTheme.textSecondary)
                        .padding()
                } else {
                    ForEach(viewModel.searchResults) { result in
                        GeocodingRowView(result: result) {
                            addCity(result)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Saved cities list
    private var savedCitiesList: some View {
        Group {
            if savedCities.isEmpty {
                Spacer()
                ContentUnavailableView(
                    "No Cities",
                    systemImage: "map",
                    description: Text("Search and add cities above.")
                )
                .foregroundStyle(AppTheme.textSecondary)
                Spacer()
            } else {
                List {
                    ForEach(savedCities) { city in
                        
                        let weather = viewModel.weathers.first(where: {
                            guard let lat = $0.coord?.lat, let lon = $0.coord?.lon else { return false }
                            return abs(lat - city.lat) < 0.5 && abs(lon - city.lon) < 0.5
                        })
                        
                        Button {
                            if let weather {
                                selectedWeather = weather
                                withAnimation(.spring(response: 0.35)) { drawerOpen = false }
                            }
                        } label: {
                            if let weather {
                                WeatherRowView(
                                    weather: weather,
                                    isImperial: viewModel.isImperial,
                                    overrideName: city.name
                                )
                            } else {
                                HStack {
                                    Text(city.name)
                                        .foregroundStyle(AppTheme.textPrimary)
                                    Spacer()
                                    ProgressView().tint(AppTheme.accentGreen)
                                }
                                .padding()
                                .glassCard()
                            }
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                modelContext.delete(city)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }

    // MARK: - Add city
    private func addCity(_ result: GeocodingResult) {
        let exists = savedCities.contains { $0.lat == result.lat && $0.lon == result.lon }
        guard !exists else { return }
        let city = SavedCity(
            name: result.localizedName,
            lat: result.lat,
            lon: result.lon,
            country: result.country
        )
        modelContext.insert(city)
        viewModel.searchText = ""
    }
}
