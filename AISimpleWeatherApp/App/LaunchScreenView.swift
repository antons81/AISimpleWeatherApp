//
//  LaunchScreenView.swift
//  WearlyWeather
//
//  Created by Anton Stremovskiy on 14.04.26.
//

import SwiftUI
import Combine

struct LaunchScreenView: View {
    
    @State private var modelText = "Loading..."
    @State private var hasTimeElapsed = false
    @ObservedObject var aiService = AIService.shared
    
    var body: some View {
        if aiService.isModelLoaded {
            NavigationStack {
                MainView()
            }
            .transition(.opacity)
        } else {
            ZStack {
                Image("startImage")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .aspectRatio(contentMode: .fill)
                
                VStack {
                    Spacer()
                    Text(aiService.isLoading ? modelText : "Warming up...")
                        .font(Font.body.weight(.thin))
                        .foregroundColor(.white)
                        .transition(AnyTransition.opacity.combined(with: .scale))
                        .id("text-component" + modelText)
                        
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(Color.white)
                        .padding(32)
                }
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}
