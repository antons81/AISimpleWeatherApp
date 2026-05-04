//
//  WeatherIconView.swift
//  AISimpleWeatherApp
//
//  Created by Anton Stremovskiy on 11.04.26.
//

import Foundation
import Combine
import SwiftUI

// DrawerViewModel.swift
import Foundation
import Combine
import SwiftData

@MainActor
final class DrawerViewModel: ObservableObject {

    @Published var weathers: [CurrentWeather] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: Error? = nil
    @Published var searchText: String = ""
    @Published var searchResults: [GeocodingResult] = []
    @Published var isSearching: Bool = false

    @AppStorage("isImperial") var isImperial = false

    var isSearchMode: Bool { !searchText.isEmpty }

    private var cancellables = Set<AnyCancellable>()
    private var service: NetworkServiceProtocol

    init() {
        self.service = NetworkService()
        setupSearch()
    }

    func setService(_ service: NetworkServiceProtocol) {
        self.service = service
    }

    // MARK: - Search with debounce

    private func setupSearch() {
        $searchText
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .filter { $0.count >= 3 } // минимум 3 символа
            .sink { [weak self] query in
                self?.searchCities(query: query)
            }
            .store(in: &cancellables)
        
        // очищаем результаты если поиск очищен
        $searchText
            .filter { $0.isEmpty }
            .sink { [weak self] _ in
                self?.searchResults = []
            }
            .store(in: &cancellables)
    }

    private func searchCities(query: String) {
        isSearching = true
        service.fetchGeocode(query: query)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isSearching = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error
                }
            } receiveValue: { [weak self] results in
                self?.searchResults = results
                self?.isSearching = false
            }
            .store(in: &cancellables)
    }

    // MARK: - Saved cities

    func loadWeather(for cities: [SavedCity]) {
        guard !cities.isEmpty else {
            weathers = []
            return
        }
        
        isLoading = true
        errorMessage = nil

        let publishers = cities.map { city in
            service.fetchCurrentWeatherByCoord(lat: city.lat, lon: city.lon)
                .map { Optional($0) }
                .replaceError(with: nil)
        }

        Publishers.MergeMany(publishers)
            .compactMap { $0 }
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                self?.weathers = results
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
}
