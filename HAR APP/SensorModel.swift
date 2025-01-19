//
//  SensorModel.swift
//  HAR APP
//
//  Created by Arman Ozkaya on 19/01/2025.
//

import Foundation

struct SensorData: Codable, Identifiable {
    let id: UUID?
    var timestamp: Double
    var accelX: String
    var accelY: String
    var accelZ: String
    var gyroX: String
    var gyroY: String
    var gyroZ: String
    var magX: String
    var magY: String
    var magZ: String
    var heartbeat: String
    var latitude: String
    var longitude: String
    var course: String
    var speed: String
    var speedAccuracy: String
    var courseAccuracy: String
    var altitude: String
    var altitudeAccuracy: String
    var coordinateAccuracy: String
    var heading: String
    var headingAccuracy: String
}
