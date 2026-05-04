//
//  WeatherAnimation.swift
//  WearlyWeather
//
//  Created by Anton Stremovskiy on 04.05.26.
//

// WeatherAnimationView.swift
import SwiftUI

struct WeatherAnimationView: View {
    let iconCode: String
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let date = timeline.date
                switch weatherType {
                case .rain:
                    drawRain(context: context, size: size, date: date)
                case .snow:
                    drawSnow(context: context, size: size, date: date)
                case .sun:
                    drawSun(context: context, size: size, date: date)
                case .clouds:
                    drawClouds(context: context, size: size, date: date)
                case .night:
                    drawStars(context: context, size: size, date: date)
                case .none:
                    break
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
    
    // MARK: - Weather type
    
    private enum WeatherType {
        case rain, snow, sun, clouds, night, none
    }
    
    private var weatherType: WeatherType {
        switch iconCode {
        case "01d": return .sun
        case "01n": return .night
        case "02d", "03d", "04d", "02n", "03n", "04n": return .clouds
        case "09d", "09n", "10d", "10n", "11d", "11n": return .rain
        case "13d", "13n": return .snow
        default: return .none
        }
    }
    
    // MARK: - Rain
    
    private func drawRain(context: GraphicsContext, size: CGSize, date: Date) {
        let time = date.timeIntervalSince1970
        let dropCount = 35
        
        for i in 0..<dropCount {
            let seed = Double(i) * 120.5
            let x = seed.truncatingRemainder(dividingBy: size.width)
            let speed = 180.0 + seed.truncatingRemainder(dividingBy: 80.0) // медленнее
            let offset = seed.truncatingRemainder(dividingBy: size.height)
            let y = (time * speed + offset).truncatingRemainder(dividingBy: size.height + 20) - 10
            
            let length = 8.0 + seed.truncatingRemainder(dividingBy: 8.0) // разная длина
            let opacity = 0.06 + seed.truncatingRemainder(dividingBy: 0.08) // тусклее
            let angle = 0.15
            
            var path = Path()
            path.move(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x + length * sin(angle), y: y + length * cos(angle)))
            
            context.stroke(path, with: .color(.white.opacity(opacity)), lineWidth: 0.8)
        }
    }
    
    // MARK: - Snow
    
    private func drawSnow(context: GraphicsContext, size: CGSize, date: Date) {
        let time = date.timeIntervalSince1970
        let flakeCount = 50
        
        for i in 0..<flakeCount {
            let seed = Double(i) * 137.5
            let x = (seed.truncatingRemainder(dividingBy: size.width))
                + sin(time * 0.5 + seed) * 15
            let speed = 40.0 + seed.truncatingRemainder(dividingBy: 30.0)
            let offset = seed.truncatingRemainder(dividingBy: size.height)
            let y = (time * speed + offset).truncatingRemainder(dividingBy: size.height + 20) - 10
            
            let rect = CGRect(x: x - 3, y: y - 3, width: 6, height: 6)
            context.fill(Circle().path(in: rect), with: .color(.white.opacity(0.25)))
        }
    }
    
    // MARK: - Sun
    
    private func drawSun(context: GraphicsContext, size: CGSize, date: Date) {
        let time = date.timeIntervalSince1970
        let cx = size.width * 0.75
        let cy = size.height * 0.18
        let rayCount = 12
        
        for i in 0..<rayCount {
            let angle = (Double(i) / Double(rayCount)) * .pi * 2 + time * 0.3
            let innerR = 55.0
            let outerR = 70.0 + sin(time * 2 + Double(i)) * 5
            
            var path = Path()
            path.move(to: CGPoint(
                x: cx + cos(angle) * innerR,
                y: cy + sin(angle) * innerR
            ))
            path.addLine(to: CGPoint(
                x: cx + cos(angle) * outerR,
                y: cy + sin(angle) * outerR
            ))
            context.stroke(path, with: .color(.yellow.opacity(0.15)), lineWidth: 2)
        }
        
        let sunRect = CGRect(x: cx - 40, y: cy - 40, width: 80, height: 80)
        context.fill(Circle().path(in: sunRect), with: .color(.yellow.opacity(0.08)))
    }
    
    // MARK: - Clouds
    
    private func drawClouds(context: GraphicsContext, size: CGSize, date: Date) {
        let time = date.timeIntervalSince1970
        let clouds: [(y: Double, speed: Double, opacity: Double, scale: Double)] = [
            (size.height * 0.15, 20.0, 0.06, 1.2),
            (size.height * 0.25, 15.0, 0.04, 0.9),
            (size.height * 0.10, 25.0, 0.05, 1.0),
        ]
        
        for cloud in clouds {
            let x = (time * cloud.speed).truncatingRemainder(dividingBy: size.width + 150) - 100
            drawCloud(context: context, x: x, y: cloud.y, scale: cloud.scale, opacity: cloud.opacity)
        }
    }
    
    private func drawCloud(context: GraphicsContext, x: Double, y: Double, scale: Double, opacity: Double) {
        let w = 120.0 * scale
        let h = 50.0 * scale
        let rect = CGRect(x: x - w/2, y: y - h/2, width: w, height: h)
        context.fill(Capsule().path(in: rect), with: .color(.white.opacity(opacity)))
        
        let bumpRect = CGRect(x: x - w * 0.1, y: y - h, width: w * 0.5, height: h * 0.9)
        context.fill(Circle().path(in: bumpRect), with: .color(.white.opacity(opacity)))
    }
    
    // MARK: - Stars
    
    private func drawStars(context: GraphicsContext, size: CGSize, date: Date) {
        let time = date.timeIntervalSince1970
        let starCount = 50
        
        for i in 0..<starCount {
            let seed = Double(i) * 137.5
            let x = seed.truncatingRemainder(dividingBy: size.width)
            let y = (seed * 1.3).truncatingRemainder(dividingBy: size.height * 0.75)
            let pulse = (sin(time * 1.2 + seed) + 1) / 2
            let opacity = 0.2 + pulse * 0.4
            let radius = 1.2 + pulse * 1.5
            
            // основная точка
            let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
            context.fill(Circle().path(in: rect), with: .color(.white.opacity(opacity)))
            
            // крестообразное свечение для ярких звёзд
            if i % 5 == 0 {
                let glowSize = radius * 3
                var h = Path()
                h.move(to: CGPoint(x: x - glowSize, y: y))
                h.addLine(to: CGPoint(x: x + glowSize, y: y))
                var v = Path()
                v.move(to: CGPoint(x: x, y: y - glowSize))
                v.addLine(to: CGPoint(x: x, y: y + glowSize))
                
                context.stroke(h, with: .color(.white.opacity(opacity * 0.3)), lineWidth: 0.5)
                context.stroke(v, with: .color(.white.opacity(opacity * 0.3)), lineWidth: 0.5)
            }
        }
    }
}
