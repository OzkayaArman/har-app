//
//  Preferences Model.swift
//  HAR APP
//
//  Created by Arman Ozkaya on 12/12/2024.
//

import Foundation
import SwiftUI

class Preferences: ObservableObject {
    @Published var accelerometer = true
    @Published var gyroscope = true
    @Published var magnetometer = true
    @Published var gps = true
    @Published var heartRateSensor = true
    @Published var sessionDuration:Double = 180 {
        didSet {
            sessionDurationView = sessionDuration
        }
    }
    @Published var sessionDurationView: Double = 180
    @Published var samplingRate: Double = 30
}
