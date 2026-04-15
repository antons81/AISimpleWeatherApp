# 🌿 Wearly Weather AI App

> A beautiful iOS weather app with on-device AI assistant built with SwiftUI + MVVM + Combine

![Swift](https://img.shields.io/badge/Swift-5.9-orange?style=flat-square&logo=swift)
![iOS](https://img.shields.io/badge/iOS-17.0+-blue?style=flat-square&logo=apple)
![MLX](https://img.shields.io/badge/MLX-on--device%20AI-green?style=flat-square)
![Architecture](https://img.shields.io/badge/Architecture-MVVM%20%2B%20Combine-purple?style=flat-square)

---

## ✨ Features

- **Real-time weather** for 17 cities worldwide via OpenWeatherMap API
- **5-day forecast** with detailed daily breakdown
- **On-device AI tips** powered by MLX — no internet required for AI
- **Streaming AI responses** — text appears token by token like ChatGPT
- **Metric / Imperial** toggle
- **Runner mode** — AI tips tailored for outdoor training
- **Glassmorphism UI** — dark green theme with glass card effects
- **Custom weather icons** — hand-crafted glassmorphism style icons

---

## 🎨 Design

### Design system

- **Style:** Glassmorphism — semi-transparent cards with subtle borders
- **Color scheme:** Dark forest green gradient background
- **Accent colors:** `#7AFF97` (green) · `#78C8FF` (blue)
- **Typography:** SF Pro Rounded throughout

### UI Screens

#### Main Screen · City List
```
┌─────────────────────────────────┐
│  World Weather          ⚙️      │
│  Metric                         │
│  ┌─────────────────────────┐    │
│  │ 🔍 Search city...       │    │
│  └─────────────────────────┘    │
│                                  │
│  ┌──┬──────────────┬────────┐   │
│  │☀️│ Berlin       │  16°C  │   │
│  │  │ Clear sky    │  13°C  │   │
│  └──┴──────────────┴────────┘   │
│  ┌──┬──────────────┬────────┐   │
│  │☁️│ Tokyo        │  19°C  │   │
│  │  │ Scattered    │  17°C  │   │
│  └──┴──────────────┴────────┘   │
│  ┌──┬──────────────┬────────┐   │
│  │🌧│ Paris        │  14°C  │   │
│  │  │ Light rain   │  11°C  │   │
│  └──┴──────────────┴────────┘   │
└─────────────────────────────────┘
```

#### Daily View · City Detail
```
┌─────────────────────────────────┐
│  ‹  Wuppertal                   │
│  ┌──────────────────────────┐   │
│  │ ☁️  Wuppertal            │   │
│  │     Sunday               │   │
│  │     Overcast clouds      │   │
│  │     12°C  /  12°C        │   │
│  └──────────────────────────┘   │
│  ┌────┐  ┌────────┐  ┌──────┐  │
│  │ 💧 │  │  💨    │  │  🌡  │  │
│  │ 56%│  │ 3 m/s  │  │ 1013 │  │
│  │Hum.│  │  Wind  │  │ hPa  │  │
│  └────┘  └────────┘  └──────┘  │
│  ┌──────────────────────────┐   │
│  │ ✦ AI Weather Tip      ↺  │   │
│  │                           │   │
│  │ Hey! Overcast skies but   │   │
│  │ 12°C is perfect for a    │   │
│  │ walk. Grab a light jacket │   │
│  │ and maybe a coffee ☕     │   │
│  └──────────────────────────┘   │
│  ┌──────────────────────────┐   │
│  │ ☁️ Monday   Overcast  8°C│   │
│  │ ☁️ Tuesday  Overcast  6°C│   │
│  │ 🌧 Thursday Light rain10°│   │
│  │ ⛅ Friday   Broken    8°C│   │
│  └──────────────────────────┘   │
└─────────────────────────────────┘
```

#### Settings Screen
```
┌─────────────────────────────────┐
│  Settings                   ✕   │
│                                  │
│  PREFERENCES                     │
│  ┌──────────────────────────┐   │
│  │ 📏 Units                  │   │
│  │    Metric / Imperial   ●─ │   │
│  └──────────────────────────┘   │
│                                  │
│  PROFILE                         │
│  ┌──────────────────────────┐   │
│  │ AI tips tailored for...   │   │
│  │  ┌──────────┐ ┌────────┐ │   │
│  │  │    🚶    │ │   🏃   │ │   │
│  │  │ Regular  │ │ Runner │ │   │
│  │  │ selected │ │        │ │   │
│  │  └──────────┘ └────────┘ │   │
│  └──────────────────────────┘   │
│                                  │
│  AI LANGUAGE                     │
│  ┌──────────────────────────┐   │
│  │ 🌐 Auto detect   Russian›│   │
│  └──────────────────────────┘   │
└─────────────────────────────────┘
```

---

## 🏗️ Architecture

### Project Structure

```
AISimpleWeatherApp/
├── App/
│   └── WorldWeatherApp.swift          ← @main, AI preload on launch
│
├── Models/
│   ├── CurrentWeatherModel.swift      ← OWM /weather response
│   ├── ForecastModel.swift            ← OWM /forecast response
│   └── CitiesList.swift               ← 17 cities enum
│
├── Services/
│   ├── NetworkService.swift           ← Combine-based API layer
│   ├── WeatherIconService.swift       ← Condition ID → icon name
│   └── AI/
│       ├── AIService.swift            ← MLX singleton, streaming
│       └── AIPromptBuilder.swift      ← Weather prompt templates
│
├── ViewModels/
│   ├── MainViewModel.swift            ← City list + search
│   └── DailyViewModel.swift          ← Forecast + AI summary
│
├── Views/
│   ├── Main/
│   │   ├── MainView.swift
│   │   └── WeatherRowView.swift
│   ├── Daily/
│   │   ├── DailyView.swift
│   │   ├── DailyHeaderView.swift
│   │   ├── StatsRowView.swift
│   │   ├── ForecastRowView.swift
│   │   └── AIForecastCard.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── Components/
│       └── WeatherIconView.swift
│
├── Extensions/
│   └── Extensions.swift              ← Double, String, UserDefaults
│
└── Design/
    └── AppTheme.swift                ← Colors, glass modifiers
```

### Data Flow

```
OpenWeatherMap API
        │
        ▼
  NetworkService          UserDefaults
  (Combine publishers)    (isImperial, isRunner)
        │                       │
        ▼                       ▼
  MainViewModel ──────► MainView
  DailyViewModel ─────► DailyView
        │
        ▼
   AIService.shared ──► AIForecastCard
   (MLX on-device LLM)   (streaming tokens)
```

---

## 🤖 On-Device AI

The AI assistant runs **completely on-device** using Apple's [MLX framework](https://github.com/ml-explore/mlx-swift-examples). No data is sent to any server for AI processing.

### Model

| Property | Value |
|----------|-------|
| Model | `Qwen3-0.6B-4bit` |
| Size | ~400 MB |
| Inference | Apple Neural Engine + GPU |
| Min device | iPhone 12+ |

### How it works

1. **App launch** — model starts loading in background via `AIService.shared.preloadModel()`
2. **Warm-up** — a short prompt is run to warm up the neural engine
3. **City opened** — AI generates weather tip using streaming
4. **Streaming** — tokens appear one by one in real time, `<think>` blocks are filtered out
5. **Modes** — Regular (casual tip) or Runner (what to wear, what to bring)

### AI Prompt example

```
You are a helpful assistant for a weather app.
Mode: a regular person going outside.
Language: Russian.
Answer in 2-3 short sentences, plain text only.

Current weather:
- Condition: light rain at night
- Temperature: 12°C
- Humidity: 92%
- Feels like: 10°C

Give a brief summary and one practical tip with light humor.
```

---

## 🛠 Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | SwiftUI |
| Architecture | MVVM + Combine |
| Networking | URLSession + Combine publishers |
| On-device AI | MLX Swift (`mlx-swift-examples`) |
| LLM | Qwen3-0.6B-4bit via `LLMRegistry` |
| Weather API | OpenWeatherMap |
| Min iOS | 17.0 |
| Language | Swift 5.9 |

---

## 📦 Dependencies (SPM)

```
https://github.com/ml-explore/mlx-swift          (v0.21.2+)
https://github.com/ml-explore/mlx-swift-examples  (v2.29.1)
```

---

## 🚀 Getting Started

### Prerequisites

- Xcode 16+
- iOS 17.0+ device (simulator won't work for MLX)
- OpenWeatherMap API key (free tier works)
- ~500 MB free storage for AI model download

### Setup

1. Clone the repo
2. Open `AISimpleWeatherApp.xcodeproj`
3. Add your OWM API key in `NetworkService.swift`:
   ```swift
   private static let apiKey = "YOUR_API_KEY_HERE"
   ```
4. Select your device (not simulator — MLX requires Metal GPU)
5. Build & Run

The AI model downloads automatically on first launch (~400 MB).

---

## ⚠️ Security Note

Move the API key to `Config.xcconfig` before shipping:

```
// Config.xcconfig
OWM_API_KEY = your_key_here
```

```swift
// NetworkService.swift
let key = Bundle.main.infoDictionary?["OWM_API_KEY"] as? String ?? ""
```

---

## 🗺 Roadmap

- [ ] Add more cities / search any city
- [ ] Widget extension for home screen
- [ ] Fine-tune AI model on weather-specific data
- [ ] Hourly forecast
- [ ] Weather alerts
- [ ] Apple Watch companion app
- [ ] Runner route suggestions based on weather

---

## 📄 License

MIT License — feel free to use, modify and distribute.

---

*Built with ❤️ and a lot of ☕ in Wuppertal, Germany*
