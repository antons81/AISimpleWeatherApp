//
//  WeatherIconView.swift
//  AISimpleWeatherApp
//
//  Created by Anton Stremovskiy on 11.04.26.
//

import SwiftUI

struct WeatherIconView: View {
    
    let iconCode: String
    var size: CGFloat = 44
    
    var body: some View {
        Image(iconCode)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083).opacity(0.6),
                                Color(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
    }
}
