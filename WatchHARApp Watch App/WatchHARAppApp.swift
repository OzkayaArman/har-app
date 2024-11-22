//
//  WatchHARAppApp.swift
//  WatchHARApp Watch App
//
//  Created by Arman Ozkaya on 02/11/2024.
//

import SwiftUI
import SwiftData

@main
struct WatchHARApp_Watch_AppApp: App {
    
    var body: some Scene {
        WindowGroup {
            WatchView()
        }
        .modelContainer(for: ModelSensorData.self)
    }
}
