// Extensions.swift
// Utility extensions preserved from the original project.
// Split into logical sections for clarity.

import Foundation
import SwiftUI
import MLXLMCommon
import MLXLLM
import MLX


// Binding

extension Binding where Value == Bool {
    init<T>(value: Binding<T?>) {
        self.init {
            value.wrappedValue != nil
        } set: { newValue in
            if !newValue {
                value.wrappedValue = nil
            }
        }
    }
}

extension Binding {
    /// Creates a Bool binding for a specific enum case.
    /// - Parameters:
    ///   - binding: The source binding (e.g., your enum).
    ///   - caseValue: The value that represents 'true'.
    ///   - onFalseValue: The value to set when toggled off.
    ///   - action: Closure for side effects.
    static func mapped<T: Equatable>(
        _ binding: Binding<T>,
        toCase caseValue: T,
        onFalseValue: T,
        action: @escaping (Bool) -> Void
    ) -> Binding<Bool> where Value == Bool {
        return Binding<Bool>(
            get: { binding.wrappedValue == caseValue },
            set: { newValue in
                binding.wrappedValue = newValue ? caseValue : onFalseValue
                action(newValue)
            }
        )
    }
}


// MARK: - Double + Temperature
extension Double {
    
    // Kelvin to Celsius Apple Style
    var toCelsiusString: String {
        let kelvin = Measurement(value: self, unit: UnitTemperature.kelvin)
        let celsius = kelvin.converted(to: .celsius)
        
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit // using only celsius
        formatter.numberFormatter.maximumFractionDigits = 0 // no floating number
        
        return formatter.string(from: celsius)
    }

    // Kelvin to Fahrenheit
    var toFahrenheitString: String {
        let kelvin = Measurement(value: self, unit: UnitTemperature.kelvin)
        let fahrenheit = kelvin.converted(to: .fahrenheit)
        
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 0
        
        return formatter.string(from: fahrenheit)
    }

    var toString: String {
        self.formatted(.number) // iOS 15+
    }
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
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }
}

nonisolated public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        let output = items.map { "\($0)" }.joined(separator: separator)
        Swift.print(output, terminator: terminator)
    #else
        Swift.print("RELEASE MODE")
    #endif
}


extension LLMRegistry {
    
    static let qwen3_0_6b_4bit = ModelConfiguration(
        id: "mlx-community/Qwen3-0.6B-4bit",
        defaultPrompt: "Why is the sky blue?"
    )
    
    static let qwen3_1_7b_4bit = ModelConfiguration(
        id: "mlx-community/Qwen3-1.7B-4bit",
        defaultPrompt: "Why is the sky blue?"
    )
}
