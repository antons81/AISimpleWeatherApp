//
//  WeatherIconView.swift
//  AISimpleWeatherApp
//
//  Created by Anton Stremovskiy on 11.04.26.
//

import Foundation
import Combine
import SwiftUI

// MARK: - MainViewModel

@MainActor
final class DrawerViewModel: ObservableObject {
    
    @EnvironmentObject private var networkService: NetworkService

    // MARK: Published state

    @Published var weathers:     [CurrentWeather] = []
    @Published var isLoading:    Bool             = false
    @Published var errorMessage: Error?           = nil
    @Published var searchText:   String           = ""
    
    // get metric value
    @AppStorage("isImperial") var isImperial = false

    // MARK: Computed — filtered list driven by searchText
    var filteredWeathers: [CurrentWeather] {
        guard !searchText.isEmpty else { return weathers }
        return weathers.filter {
            $0.name?.localizedCaseInsensitiveContains(searchText) ?? false
        }
    }

    // MARK: Private
    private var cancellables = Set<AnyCancellable>()
    private var service: NetworkServiceProtocol
    
    init() {
        self.service = NetworkService()
    }
    
    func setService(_ service: NetworkServiceProtocol) {
        self.service = service
    }

    // MARK: - Public API
    /// Load weather for all cities in parallel, then merge results.
    func loadWeather() {
        isLoading    = true
        errorMessage = nil

        let publishers = City.allCities.map {
            service.fetchCurrentWeather(for: $0)
                .map { Optional($0) }
                .replaceError(with: nil)  // individual city failure does not cancel all
        }

        Publishers.MergeMany(publishers)
            .compactMap { $0 }
            .collect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                self?.weathers  = results
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }

    /// Toggle metric / imperial and persist the choice.
    func setImperial(_ value: Bool) {
        isImperial           = value
        UserDefaults.isImperial = value
    }
}
