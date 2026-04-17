//
//  LaunchScreenView.swift
//  WearlyWeather
//
//  Created by Anton Stremovskiy on 14.04.26.
//

import SwiftUI
import Combine

struct LaunchScreenView: View {
    
    @EnvironmentObject var localAIService: LocalAIService
    @AppStorage("ai_provider") private var aiProvider: AIProvider = .local
    @Binding var isReady: Bool
    
    var body: some View {
        ZStack {
            Image("startImage")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                Text("Warming up...")
                    .foregroundColor(.white)
                    .font(.custom("serif", size: 16).weight(.thin))
                    .padding(.bottom, 20)
                ProgressView().tint(.white)
            }
            .padding(.bottom, 50)
        }
        .onAppear {
            if aiProvider == .cloud {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    isReady = true
                }
            } else {
                if localAIService.isModelLoaded {
                    isReady = true
                } else {
                    Task { await localAIService.preloadModel() }
                }
            }
        }
        
        .onChange(of: localAIService.isModelLoaded) { _, loaded in
            if loaded && aiProvider == .local {
                withAnimation {
                    isReady = true
                }
            }
        }
    }
}

#Preview {
    let ready: Binding<Bool> = .constant(false)
    LaunchScreenView(isReady: ready).environmentObject(LocalAIService.shared)
}
