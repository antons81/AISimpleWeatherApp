// WorldWeatherApp.swift
// Entry point for the SwiftUI app (replaces AppDelegate + SceneDelegate)

import SwiftUI
import Firebase


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        if FirebaseApp.allApps?.isEmpty ?? true {
            FirebaseApp.configure()
            print("--- Firebase Configured Successfully ---")
        }
        return true
    }
}

@main
struct WearlyWeatherApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var isSplashScreenDismissed = false
    
    @AppStorage("ai_provider") private var aiProvider: AIProvider = .local
    @StateObject private var localAIService = LocalAIService.shared // AI Service
    @State private var isAppReady = false
    
    
    
    var body: some Scene {
        WindowGroup {
            
            Group { // Используем Group вместо ZStack
                if !isAppReady {
                    LaunchScreenView(isReady: $isAppReady)
                } else {
                    NavigationStack {
                        MainView()
                    }
                    .transition(.opacity)
                }
            }
            .environmentObject(localAIService)
            .id(isAppReady)
            .onChange(of: scenePhase) { oldPhase, newPhase in
                handleSceneChange(to: newPhase)
            }
        }
    }
    
    private func handleSceneChange(to phase: ScenePhase) {
        switch phase {
        case .active:
            if aiProvider == .local && !localAIService.isModelLoaded {
                print("🔄 App Active: Loading Local AI as per settings")
                Task { await localAIService.preloadModel() }
            }
            
        case .background:
            print("💤 App Background: Unloading model to save memory")
            localAIService.releaseModel()
            
        default:
            break
        }
    }
}


