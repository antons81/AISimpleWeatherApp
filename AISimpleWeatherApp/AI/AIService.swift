//
//  AIService.swift
//  AISimpleWeatherApp
//
//  Created by Anton Stremovskiy on 12.04.26.
//

import Foundation
import Combine
import MLXLLM
import MLX
import MLXLMCommon
internal import Tokenizers


@MainActor
final class AIService: ObservableObject {
    
    // Singleton — одна загруженная модель на всё приложение
    static let shared = AIService()
    
    @Published var isLoading = false
    @Published var isModelLoaded = false
    @Published var output = ""
    @Published var isGenerating = false
    @Published var displayOutput = ""
    
    private var modelContainer: ModelContainer?
    
    private let modelConfig = LLMRegistry.llama3_2_1B_4bit
    
    private let generateParameters = GenerateParameters(
        maxTokens: 200,
        temperature: 0.5
    )
    
    
    // warm up model
    private func warmUpModel() async {
        guard let container = modelContainer else { return }
        
        print("🔥 doing model warm-up ...")
        
        let warmPrompt = "Hello, say something to me!"
        
        do {
            _ = try await container.perform { context in
                let input = try await context.processor.prepare(
                    input: UserInput(messages: [["role": "user", "content": warmPrompt]])
                )
                
                return try MLXLMCommon.generate(
                    input: input,
                    parameters: GenerateParameters(maxTokens: 10),
                    context: context
                )
            }
            print("✅ Warm-up completed")
        } catch {
            print("Warm-up failed: \(error)")
        }
    }
    
    
    // preload Model
    func preloadModel() async {
        if modelContainer != nil { return }
        
        do {
            modelContainer = try await LLMModelFactory.shared.loadContainer(
                configuration: modelConfig
            ) { progress in
                print("🔄 Model preloading: \(Int(progress.fractionCompleted * 100))%")
            }
            
            isModelLoaded = true
            print("✅ AI Model preloaded successfully")
            await warmUpModel()
            
            
        } catch {
            print("❌ Preload error: \(error)")
        }
    }
    
    // load model only once
    func loadModel() async {
        if modelContainer != nil { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            modelContainer = try await LLMModelFactory.shared.loadContainer(
                configuration: modelConfig
            ) { progress in
                print("Downloading: \(Int(progress.fractionCompleted * 100))%")
            }
            isModelLoaded = true
            print("✅ AI Model loaded successfully")
        } catch {
            print("❌ Model load error: \(error)")
        }
    }
    
    // Новая основная функция с streaming
    func generateSummary(prompt: String) async {
        guard !isGenerating else {
            print("⚠️ Already generating, skip")
            return
        }
        
        isGenerating = true
        output = ""
        
        if modelContainer == nil {
            await preloadModel()
        }
        
        guard let container = modelContainer else {
            output = "Model not loaded"
            isGenerating = false
            return
        }
        
        print("🚀 Starting generation...")
        
        do {
            let _ = try await container.perform { context in
                print("📝 Preparing input...")
                let input = try await context.processor.prepare(
                    input: UserInput(messages: [["role": "user", "content": prompt]])
                )
                print("⚡️ Input ready, generating...")
                
                return try MLXLMCommon.generate(
                    input: input,
                    parameters: GenerateParameters(maxTokens: 50, temperature: 0.7),
                    context: context,
                    didGenerate: { (tokens: [Int]) -> GenerateDisposition in
                        let text = context.tokenizer.decode(tokens: tokens)
                        Task { @MainActor [weak self] in
                            guard let self else { return }
                            // output накапливается полностью
                            self.output = text
                            
                            // displayOutput = последнее декодированное значение (весь текст целиком)
                            // но берём только новый кусок — последние символы
                            self.displayOutput = text
                        }
                        return .more
                    }
                )
            }
            print("✅ Generation complete, output: \(output.prefix(50))")
        } catch {
            print("❌ Generation error: \(error)")
            output = "Error: \(error.localizedDescription)"
        }
        
        isGenerating = false
    }
    
    // old function
    func ask(_ prompt: String) async -> String {
        await generateSummary(prompt: prompt)
        return output
    }
}

