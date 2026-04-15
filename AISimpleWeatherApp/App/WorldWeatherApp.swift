// WorldWeatherApp.swift
// Entry point for the SwiftUI app (replaces AppDelegate + SceneDelegate)

import SwiftUI

@main
struct WorldWeatherApp: App {
    
    private let aiService = AIService.shared // AI Service
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            LaunchScreenView()
                .environmentObject(aiService)
            
                .onChange(of: scenePhase) { oldValue, newValue in
                    switch newValue {
                    case .background:
                        print("🍏 App moved to from \(oldValue) to background")
                        aiService.releaseModel()
                    case .inactive: break
                    case .active:
                        print("🍏 App is now active")
                        Task {
                            print("🍏 Preloading model")
                            await aiService.preloadModel()
                        }
                    @unknown default:
                        break
                    }
                }
        }
    }
}

