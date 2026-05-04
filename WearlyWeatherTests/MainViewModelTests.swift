//
//  MainViewModelTests.swift
//  AISimpleWeatherApp
//
//  Created by Anton Stremovskiy on 14.04.26.
//


import XCTest
import Combine
@testable import WearlyWeather

//@MainActor
//final class MainViewModelTests: XCTestCase {
//    
//    var cancellables = Set<AnyCancellable>()
//    
//    func test_loadWeather_populatesWeathers() async {
//        let mock = MockNetworkService()
//        mock.mockWeather = makeWeather(name: "Wuppertal")
//        
//        let vm = MainViewModel(service: mock as? NetworkServiceProtocol)
//        vm.loadWeather()
//        
//        // Даём время на async операцию
//        try? await Task.sleep(nanoseconds: 500_000_000)
//        
//        XCTAssertFalse(vm.weathers.isEmpty)
//        XCTAssertEqual(vm.weathers.first?.name, "Wuppertal")
//    }
//    
//    func test_searchFilter_filtersCorrectly() async {
//        let mock = MockNetworkService()
//        mock.mockWeather = makeWeather(name: "Wuppertal")
//        
//        let vm = MainViewModel(service: mock as? NetworkServiceProtocol)
//        vm.loadWeather()
//        try? await Task.sleep(nanoseconds: 500_000_000)
//        
//        vm.searchText = "Wup"
//        XCTAssertTrue(vm.filteredWeathers.allSatisfy {
//            $0.name?.contains("Wup") ?? false
//        })
//    }
//    
//    func test_searchFilter_emptyReturnsAll() async {
//        let mock = MockNetworkService()
//        mock.mockWeather = makeWeather(name: "Wuppertal")
//        
//        let vm = MainViewModel(service: mock as? NetworkServiceProtocol)
//        vm.loadWeather()
//        try? await Task.sleep(nanoseconds: 500_000_000)
//        
//        vm.searchText = ""
//        XCTAssertEqual(vm.filteredWeathers.count, vm.weathers.count)
//    }
//    
//    func test_setImperial_persists() {
//        let vm = MainViewModel(service: MockNetworkService() as? NetworkServiceProtocol)
//        vm.setImperial(true)
//        XCTAssertTrue(UserDefaults.isImperial)
//        XCTAssertTrue(vm.isImperial)
//        vm.setImperial(false) // cleanup
//    }
//    
//    // MARK: - Helpers
//    
//    private func makeWeather(name: String) -> CurrentWeather {
//        // Создаём через JSON декодирование
//        let json = """
//        {
//            "name": "\(name)",
//            "coord": { "lat": 52.52, "lon": 13.405 },
//            "weather": [{ "id": 800, "main": "Clear", "description": "clear sky", "icon": "01d" }],
//            "main": { "temp": 289.15, "feels_like": 287.0, "temp_min": 287.0, "temp_max": 291.0, "pressure": 1013, "humidity": 45 },
//            "wind": { "speed": 3.5 },
//            "sys": { "country": "DE", "sunrise": 1700000000, "sunset": 1800000000 }
//        }
//        """.data(using: .utf8)!
//        return try! JSONDecoder().decode(CurrentWeather.self, from: json)
//    }
//}
//
