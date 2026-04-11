//
//  WeatherIconView.swift
//  AISimpleWeatherApp
//
//  Created by Anton Stremovskiy on 11.04.26.
//
import SwiftUI

struct DailyView: View {
    
    let cityName: String
    let lat:      Double
    let lon:      Double
    
    @StateObject private var viewModel = DailyViewModel()
    
    
    var body: some View {
        
        ZStack(alignment: .center) {
            
            LinearGradient(
                colors: [
                    Color(red: 0.92, green: 0.96, blue: 1.00),
                    Color(red: 0.86, green: 0.93, blue: 0.99)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 10) {
                    
                    if let selected = viewModel.selectedDay {
                        DailyHeaderView(item: selected, cityName: cityName)
                            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                            .frame(maxWidth: .infinity)
                    }
                    
                    
                    AIForecastCard(text: "Ai Forecast...")
                    
                    LazyVStack(spacing: 8) {
                                ForEach(viewModel.forecastDays) { item in
                                    ForecastRowView(item: item)
                                        .padding(.horizontal, 16)           // вместо listRowInsets
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            viewModel.selectedDay = item
                                        }
                                }
                            }
                            
                            Spacer(minLength: 40)   // приятный отступ снизу
                }
                Spacer(minLength: 20)
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.15))
                }
            }
            .navigationTitle(cityName)
            .navigationBarTitleDisplayMode(.inline)
            .alert(
                "Loading Error",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                ),
                actions: { Button("OK", role: .cancel) {} },
                message: { Text(viewModel.errorMessage ?? "") }
            )
            .task {
                viewModel.loadForecast(lat: lat, lon: lon)
            }
        }
    }
}



struct AIForecastCard: View {
    
    let text: String
    @State private var tip1 = Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1));
    @State private var tip2 = Color(#colorLiteral(red: 0.08327483386, green: 0.08977312595, blue: 0.1014031693, alpha: 0.16));
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(text)
                .font(.system(size: 14, weight: .light, design: .rounded))
                .padding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(gradient: Gradient(colors: [tip1, tip2]),
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
        .padding(.horizontal, 16)
    }
}

// MARK: - Preview


#Preview {
    NavigationStack {
        DailyView(cityName: "Berlin", lat: 52.52, lon: 13.405)
    }
}
