// Extensions.swift
// Utility extensions preserved from the original project.
// Split into logical sections for clarity.

import Foundation
import SwiftUI
import MLXLMCommon
import MLXLLM
import MLX

// MARK: - Double + Temperature

extension Double {

    /// Converts Kelvin → Celsius string, e.g. "22℃"
    var toCelsiusString: String {
        "\((self - 273.15).formatted(.number.precision(.fractionLength(0))))℃"
    }

    /// Converts Kelvin → Fahrenheit string, e.g. "72℉"
    var toFahrenheitString: String {
        let f = (self - 273.15) * 1.8 + 32
        return "\(f.formatted(.number.precision(.fractionLength(0))))℉"
    }

    var toString: String { String(self) }
}

// MARK: - String + Formatting

extension String {

    /// Capitalises only the very first character of the string.
    func capitalizingFirstLetter() -> String {
        guard let first = self.first else { return self }
        return first.uppercased() + dropFirst()
    }
}

// MARK: - UserDefaults + isImperial flag

extension UserDefaults {

    private static let imperialKey = "isImperial"

    /// Whether the user prefers imperial units (Fahrenheit). Defaults to false (Celsius).
    static var isImperial: Bool {
        get { standard.bool(forKey: imperialKey) }
        set { standard.set(newValue, forKey: imperialKey) }
    }
}

extension Date {
    var timeOfDayDescription: String {
        let hour = Calendar.current.component(.hour, from: self)
        
        switch hour {
        case 5..<12:  return "morning"
        case 12..<17: return "afternoon"
        case 17..<22: return "evening"
        default:      return "night"
        }
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" // 24-часовой формат
        return formatter.string(from: self)
    }
}

//extension LLMRegistry {
//    
//    static let qwen3_0_6b_4bit = ModelConfiguration(
//        id: "mlx-community/Qwen3-0.6B-4bit",
//        defaultPromptFormat: .
//    )
//    
//    // Можно добавить и другие:
//    static let qwen3_1_7b_4bit = ModelConfiguration(
//        id: "mlx-community/Qwen3-1.7B-4bit",
//        defaultPromptFormat: .qwen
//    )
//}
