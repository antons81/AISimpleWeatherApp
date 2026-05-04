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
    
    @AppStorage("ai_provider") private var aiProvider: AIProvider = .local
    @StateObject private var localAIService = LocalAIService.shared // AI Service
    @StateObject private var networkService = NetworkService()
    @StateObject private var locationManager = LocationManager()
    @State private var isAppReady = false
    
    
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !isAppReady {
                    LaunchScreenView(isReady: $isAppReady)
                } else {
                    NavigationStack {
                        //MainView()
                        RootView()
                    }
                    .transition(.opacity)
                }
            }
            .environmentObject(localAIService)
            .environmentObject(networkService)
            .environmentObject(locationManager)
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
                print("🔄 App Active: Loading local AI...")
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


