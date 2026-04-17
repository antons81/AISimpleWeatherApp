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
    
    // Singleton
    static let shared = AIService()
    
    @Published var isLoading = false
    @Published var isModelLoaded = false
    @Published var output = ""
    @Published var isGenerating = false
    @Published var displayOutput = ""
    
    private var modelContainer: ModelContainer?
    
    private let modelConfig = LLMRegistry.llama3_2_1B_4bit
    
    private let generateParameters = GenerateParameters (
        maxTokens: 512,
        temperature: 0.7,
        repetitionPenalty: 1.2
    )
    
    
    // warm up model
    private func warmUpModel() async {
        
        guard let container = modelContainer else { return }
        
        IFF_DEBUG: do {
            print("🔥 doing model warm-up ...")
        }
        
        let warmPrompt = "Hello, say something to me!"
        
        do {
            _ = try await container.perform { context in
                let input = try await context.processor.prepare(
                    input: UserInput(messages: [["role": "user", "content": warmPrompt]])
                )
                
                return try MLXLMCommon.generate(
                    input: input,
                    parameters: GenerateParameters(maxTokens: 100, temperature: 0.3),
                    context: context
                )
            }
            
            IFF_DEBUG: do {
                print("✅ Warm-up completed")
            }
            
        } catch {
            
            IFF_DEBUG: do {
                print("Warm-up failed: \(error)")
            }
            
        }
    }
    
    
    // preload Model
    func preloadModel() async {
        
        guard modelContainer == nil else { return }
        
        MLX.GPU.clearCache()
        
        await MainActor.run { self.isLoading = true }
        
        do {
            let container = try await Task.detached(priority: .userInitiated) {
                try await LLMModelFactory.shared.loadContainer(
                    configuration: self.modelConfig
                ) { progress in
                    print("🔄 Loading: \(Int(progress.fractionCompleted * 100))%")
                }
            }.value
            
            await MainActor.run {
                self.modelContainer = container
                self.isModelLoaded = true
                self.isLoading = false
                print("✅ AI Model preloaded and warmed up")
            }
            
            await warmUpModel()
            
            
        } catch {
            print("❌ Preload error: \(error.localizedDescription)")
        }
    }
    
    // load model only once
    func loadModel() async {
        guard modelContainer == nil else { return }
        
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
    
    // new streaming function
    func generateSummary(prompt: String) async {
        
        guard !isGenerating else {
            print("⚠️ Already generating, skip")
            return
        }
        
        await MainActor.run {
            isGenerating = true
            output = ""
        }
        
        defer {
            Task { @MainActor in
                isGenerating = false
                print("🏁 Generation flag reset to false")
            }
        }
        
        if modelContainer == nil {
            await preloadModel()
        }
        
        guard let container = modelContainer else {
            output = "Model not loaded"
            isGenerating = false
            return
        }
        
        IFF_DEBUG: do {
            print("🚀 Starting generation...")
        }
        
        do {
            let _ = try await container.perform { context in
                
                IFF_DEBUG: do {
                    print("📝 Preparing input...")
                }
                
                let input = try await context.processor.prepare(
                    input: UserInput(messages: [["role": "user", "content": prompt]])
                )
                
                print("⚡️ Input ready, generating...")
                
                return try MLXLMCommon.generate(
                    input: input,
                    parameters: generateParameters,
                    context: context,
                    didGenerate: { (tokens: [Int]) -> GenerateDisposition in
                        let text = context.tokenizer.decode(tokens: tokens)
                        Task { @MainActor [weak self] in
                            guard let self else { return }
                            // output full collection
                            self.output = text
                            
                            // displayOutput = last decoded value
                            // but taking new piece only
                            self.displayOutput = text
                        }
                        return .more
                    }
                )
            }
            
            IFF_DEBUG: do {
                print("✅ Generation complete, output: \(output.prefix(50))")
            }
            
            isGenerating = false
        } catch {
            
            IFF_DEBUG: do {
                print("❌ Generation error: \(error)")
            }
            
            output = "Error: \(error.localizedDescription)"
            isGenerating = false
        }
    }
    
    func releaseModel() {
        self.modelContainer = nil
        MLX.GPU.clearCache()
        print("♻️ Model memory released")
    }
    
    // old function
    func ask(_ prompt: String) async -> String {
        await generateSummary(prompt: prompt)
        return output
    }
}

