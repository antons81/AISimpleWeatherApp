// DailyViewModel.swift
// MVVM + Combine ViewModel for the daily forecast screen.
// Replaces the old DailyWeatherViewModel (NSObject + UITableViewDataSource/Delegate).

import Foundation
import Combine
import SwiftUI

// MARK: - DailyViewModel

@MainActor
final class DailyViewModel: ObservableObject {

    // MARK: Published state

    @Published var forecastDays:  [ForecastItem] = []
    @Published var selectedDay:   ForecastItem?  = nil
    @Published var isLoading:     Bool           = false
    @Published var errorMessage:  String?        = nil
    @Published var aiSummary: String             = ""
    @Published var isGenerating: Bool            = false
    @Published var cityName: String              = ""
    @Published var isAILoading: Bool             = false
    
    // MARK: Storage
    @AppStorage("ai_provider") private var aiProvider: AIProvider = .local
    
    let aiService: AIConsultant

    // MARK: Private
    private let localAI = LocalAIService.shared
    private let geminiAI = CloudGeminiService()
    private var cancellables = Set<AnyCancellable>()
    private let service: NetworkServiceProtocol
    

    // MARK: Init
    
    init(service: NetworkServiceProtocol? = nil, aiService: AIConsultant) {
        self.service = service ?? NetworkService.shared
        self.aiService = aiService
        self.cancellables = Set<AnyCancellable>()
    }

    // MARK: - Public API
    func generateAISummary(for weather: ForecastItem, type: AISummaryType) async {
        
        await MainActor.run { isGenerating = true }
        aiSummary = "" // Clear previous text
        
        do {
                    if aiProvider == .local {
                        
                        if localAI.isModelLoaded {
                            print("🤖 Request to Llama...")
                            try await localAI.generateWeatherSummary(for: weather, type: type, city: cityName) { [weak self] update in
                                self?.aiSummary = update
                            }
                        } else {
                            self.aiSummary = "Local model is not available. Try to refresh."
                        }
                    } else {
                        print("☁️ Request to Gemini Cloud...")
                        _ = try await geminiAI.generateWeatherSummary(for: weather, type: type, city: cityName) {  [weak self] result in
                             self?.aiSummary = result
                        }
                        
                    }
                } catch {
                    print("❌ AI Error: \(error)")
                    await MainActor.run { self.aiSummary = "generation failed" }
                }
                
                await MainActor.run { isGenerating = false }
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

