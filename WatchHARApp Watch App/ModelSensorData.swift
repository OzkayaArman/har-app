//
//  ModelSensorData.swift
//  WatchHARApp Watch App
//
//  Created by Arman Ozkaya on 21/11/2024.
//

import Foundation
import SwiftData

//This class will be filled in by the sensor data obtained from coremotion
//GAP: For writing manual codable protocol conformance https://www.donnywals.com/making-your-swiftdata-models-codable/
@Model
class ModelSensorData: Codable{
    
    enum CodingKeys: CodingKey {
        case timestamp
        case accelX
        case accelY
        case accelZ
        case gyroX
        case gyroY
        case gyroZ
        case magX
        case magY
        case magZ
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.timestamp = try container.decode(Double.self, forKey: .timestamp)
        self.accelX = try container.decode(String.self, forKey: .accelX)
        self.accelY = try container.decode(String.self, forKey: .accelY)
        self.accelZ = try container.decode(String.self, forKey: .accelZ)
        self.gyroX = try container.decode(String.self, forKey: .gyroX)
        self.gyroY = try container.decode(String.self, forKey: .gyroY)
        self.gyroZ = try container.decode(String.self, forKey: .gyroZ)
        self.magX = try container.decode(String.self, forKey: .magX)
        self.magY = try container.decode(String.self, forKey: .magY)
        self.magZ = try container.decode(String.self, forKey: .magZ)
    }
    
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
    
    // Computed Variable describes the sensor data, useful for testing
    var description: String {
            return """
            SensorData:
            Timestamp: \(String(describing: timestamp))
            Accelerometer - X: \(String(describing: accelX)), Y: \(String(describing: accelY)), Z: \(String(describing: accelZ))
            Gyroscope - X: \(String(describing: gyroX)), Y: \(String(describing: gyroY)), Z: \(String(describing: gyroZ))
            Magnetometer - X: \(String(describing: magX)), Y: \(String(describing: magY)), Z: \(String(describing: magZ))
            """
        }
    
    init( timestamp: Double = Date().timeIntervalSince1970,accelX: String = "0.0", accelY: String = "0.0", accelZ: String = "0.0", gyroX: String = "0.0", gyroY: String = "0.0", gyroZ: String = "0.0", magX: String = "0.0", magY: String = "0.0", magZ: String = "0.0") {
        self.timestamp = timestamp
        self.accelX = accelX
        self.accelY = accelY
        self.accelZ = accelZ
        self.gyroX = gyroX
        self.gyroY = gyroY
        self.gyroZ = gyroZ
        self.magX = magX
        self.magY = magY
        self.magZ = magZ
    }
    
}

extension ModelSensorData {
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(accelX, forKey: .accelX)
        try container.encode(accelY, forKey: .accelY)
        try container.encode(accelZ, forKey: .accelZ)
        try container.encode(gyroX, forKey: .gyroX)
        try container.encode(gyroY, forKey: .gyroY)
        try container.encode(gyroZ, forKey: .gyroZ)
        try container.encode(magX, forKey: .magX)
        try container.encode(magY, forKey: .magY)
        try container.encode(magZ, forKey: .magZ)
    }
}
