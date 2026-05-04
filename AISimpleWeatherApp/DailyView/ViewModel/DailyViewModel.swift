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

    @Published var isLoading:     Bool           = false
    @Published var errorMessage:  String?        = nil
    @Published var aiSummary: String             = ""
    @Published var isGenerating: Bool            = false
    @Published var cityName: String              = ""
    @Published var isAILoading: Bool             = false
    
    @Published var todayDayTemp: Double?         = nil
    @Published var todayNightTemp: Double?       = nil
    
    @Published var forecastDays:  [DailyWeather] = []
    @Published var selectedDay:   DailyWeather?  = nil
    
    // MARK: Storage
    @AppStorage("ai_provider") private var aiProvider: AIProvider = .local
    
    let aiService: AIConsultant

    // MARK: Private
    private let localAI = LocalAIService.shared
    private let geminiAI = CloudGeminiService()
    private var cancellables = Set<AnyCancellable>()
    private var service: NetworkServiceProtocol
    

    // MARK: Init
    
    init(aiService: AIConsultant) {
        self.service = NetworkService()
        self.aiService = aiService
        self.cancellables = Set<AnyCancellable>()
    }

    func setService(_ service: NetworkServiceProtocol) {
        self.service = service
    }

    // MARK: - Public API
    func generateAISummary(for weather: DailyWeather, type: AISummaryType) async {
        await MainActor.run { isGenerating = true }
        aiSummary = ""
        
        let context = WeatherContext(daily: weather)
        
        do {
            if aiProvider == .local {
                if localAI.isModelLoaded {
                    try await localAI.generateWeatherSummary(for: context, type: type, city: cityName) { [weak self] update in
                        self?.aiSummary = update
                    }
                } else {
                    self.aiSummary = "Local model is not available."
                }
            } else {
                _ = try await geminiAI.generateWeatherSummary(for: context, type: type, city: cityName) { [weak self] result in
                    self?.aiSummary = result
                }
            }
        } catch {
            let message = error.localizedDescription
            await MainActor.run {
                if message.contains("high demand") || message.contains("overloaded") {
                    self.aiSummary = "AI service is temporarily busy. Please try again."
                } else {
                    self.aiSummary = "Generation failed. Please try again."
                }
            }
        }
        
        await MainActor.run { isGenerating = false }
    }
    
    func loadForecast(lat: Double, lon: Double, type: AISummaryType) {
        isLoading    = true
        errorMessage = nil

        service.fetchOneCall(lat: lat, lon: lon)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] oneCall in
                guard let self else { return }
                self.todayDayTemp   = oneCall.daily.first?.temp.day
                self.todayNightTemp = oneCall.daily.first?.temp.min
                self.forecastDays   = Array(oneCall.daily.dropFirst())
                self.selectedDay    = oneCall.daily.first
                
                if let today = oneCall.daily.first {
                    Task {
                        await self.generateAISummary(for: today, type: type)
                    }
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Private helpers

    /// Groups items by calendar day, picks one per day, sorts ascending, drops today.
    private func processItems(_ items: [DailyWeather], type: AISummaryType) {
        let grouped = Dictionary(
            grouping: items,
            by: { dateKey(for: $0.dt) }
        )

        let reduced: [DailyWeather] = grouped.compactMapValues(\.first).values
            .sorted {
                ($0.dt) < ($1.dt)
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

