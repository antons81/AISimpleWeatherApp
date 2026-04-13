// DailyViewModel.swift
// MVVM + Combine ViewModel for the daily forecast screen.
// Replaces the old DailyWeatherViewModel (NSObject + UITableViewDataSource/Delegate).

import Foundation
import Combine

// MARK: - DailyViewModel

@MainActor
final class DailyViewModel: ObservableObject {

    // MARK: Published state

    @Published var forecastDays:  [ForecastItem] = []
    @Published var selectedDay:   ForecastItem?  = nil
    @Published var isLoading:     Bool           = false
    @Published var errorMessage:  String?        = nil
    @Published var aiSummary: String = ""
    
    let aiService = AIService.shared

    // MARK: Private

    private var cancellables = Set<AnyCancellable>()
    private let service: NetworkService
    

    // MARK: Init
    
    init(service: NetworkService? = nil) {
        self.service = service ?? .shared
        
        // subscribe to output AIService
        aiService.$displayOutput
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                self?.aiSummary = value  // просто присваиваем, не +=
            }
            .store(in: &cancellables)
    }

    // MARK: - Public API
    func generateAISummary(for weather: ForecastItem, type: AISummaryType) async {
        let prompt = AIPromptBuilder.weatherSummary(for: weather, type: type)
        
        // new function for streaming
        await aiService.generateSummary(prompt: prompt)
        
        // final result
        //self.aiSummary = aiService.output
    }


    /// Fetch 5-day forecast and reduce to one representative entry per day.
    func loadForecast(lat: Double, lon: Double, type: AISummaryType) {
        isLoading    = true
        errorMessage = nil

        service.fetchForecast(lat: lat, lon: lon)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] items in
                self?.processItems(items, type: type)
            }
            .store(in: &cancellables)
    }

    // MARK: - Private helpers

    /// Groups items by calendar day, picks one per day, sorts ascending, drops today.
    private func processItems(_ items: [ForecastItem], type: AISummaryType) {
        let grouped = Dictionary(
            grouping: items,
            by: { dateKey(for: $0.dt ?? 0) }
        )

        let reduced: [ForecastItem] = grouped.compactMapValues(\.first).values
            .sorted {
                ($0.dt ?? 0) < ($1.dt ?? 0)
            }
            .dropFirst()
            .map { $0 }
        
        forecastDays = reduced
        selectedDay  = items.first
        
        if let today = items.first {
            Task {
                await generateAISummary(for: today, type: .normal)
            }
        }
    }

    private func dateKey(for timestamp: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone   = TimeZone.current
        return formatter.string(from: date)
    }
}

