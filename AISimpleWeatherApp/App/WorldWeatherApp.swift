// WorldWeatherApp.swift
// Entry point for the SwiftUI app (replaces AppDelegate + SceneDelegate)

import SwiftUI

@main
struct WorldWeatherApp: App {
    
    private let aiService = AIService.shared // AI Service
    
    var body: some Scene {
        WindowGroup {
            LaunchScreenView()
                .environmentObject(aiService)
                .task {
                    await aiService.preloadModel()
                }
        }
    }
}
