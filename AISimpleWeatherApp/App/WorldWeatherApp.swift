// WorldWeatherApp.swift
// Entry point for the SwiftUI app (replaces AppDelegate + SceneDelegate)

import SwiftUI
import Firebase


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct WorldWeatherApp: App {
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    
    private let aiService = AIService.shared // AI Service
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            LaunchScreenView()
                .environmentObject(aiService)
            
                .onChange(of: scenePhase) { oldValue, newValue in
                    switch newValue {
                    case .background:
                        print("👌 App moved to from \(oldValue) to background")
                        aiService.releaseModel()
                    case .active:
                        print("👌 App is now active")
                        Task {
                            print("🍏 Preloading model")
                            await aiService.preloadModel()
                        }
                    case .inactive: break
                    @unknown default:
                        break
                    }
                }
        }
    }
}

