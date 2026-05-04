//
//  RootView.swift
//  WearlyWeather
//
//  Created by Anton Stremovskiy on 04.05.26.
//

// RootView.swift
import SwiftUI

struct RootView: View {
    
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject var networkService: NetworkService
    @State var drawerOpen = false
    @State var selectedWeather: CurrentWeather? = nil
    @State var selectedCityName: String = ""
    private let drawerWidth = UIScreen.main.bounds.width * 0.78
    
    var body: some View {
        ZStack(alignment: .leading) {
            HomeView(drawerOpen: $drawerOpen, selectedWeather: $selectedWeather, selectedCityName: $selectedCityName)
                .environmentObject(locationManager)
            
            if drawerOpen {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35)) { drawerOpen = false }
                    }
                
                DrawerView(drawerOpen: $drawerOpen, selectedWeather: $selectedWeather, selectedCityName: $selectedCityName)
                    .frame(width: drawerWidth)
                    .transition(.move(edge: .leading))
                    .environmentObject(locationManager)
            }
        }
        .animation(.spring(response: 0.35), value: drawerOpen)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 60 {
                        withAnimation(.spring(response: 0.35)) { drawerOpen = true }
                    } else if value.translation.width < -60 {
                        withAnimation(.spring(response: 0.35)) { drawerOpen = false }
                    }
                }
        )
    }
}
