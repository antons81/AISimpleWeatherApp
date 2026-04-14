//
//  LaunchScreenView.swift
//  WearlyWeather
//
//  Created by Anton Stremovskiy on 14.04.26.
//

import SwiftUI
import Combine

struct LaunchScreenView: View {
    
    @State private var isPresented: Bool = false
    @State private var modelText = "Loading..."
    @State private var hasTimeElapsed = false
    
    var body: some View {
        if isPresented {
            NavigationStack {
                MainView()
            }
        } else {
            ZStack {
                Image("startImage")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .aspectRatio(contentMode: .fill)
                
                VStack {
                    Spacer()
                    Text(hasTimeElapsed ? "Model warming up..." : "Loading...")
                        .font(Font.body.weight(.thin))
                        .foregroundColor(.white)
                        .transition(AnyTransition.opacity.combined(with: .scale))
                        .id("text-component" + modelText)
                        .onAppear(perform: delayText)
                        
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(Color.white)
                        .padding(32)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                    self.isPresented = true
                }
            }
        }
    }
    
    private func delayText() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            hasTimeElapsed = true
        }
    }
}

#Preview {
    LaunchScreenView()
}
