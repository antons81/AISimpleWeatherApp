//
//  UIExtensions.swift
//  WearlyWeather
//
//  Created by Anton Stremovskiy on 04.05.26.
//

import SwiftUI

struct CustomText: View {
    
    let text: String
    let size: CGFloat
    var weight: Font.Weight? = nil
    let design: Font.Design
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: size, design: design))
            .foregroundStyle(color)
            .lineLimit(1)
    }
}
