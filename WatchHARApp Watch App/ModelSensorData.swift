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
        case heartbeat
        case latitude
        case longitude
        case course
        case speed
        case speedAccuracy
        case courseAccuracy
        case altitude
        case altitudeAccuracy
        case coordinateAccuracy
        case heading
        case headingAccuracy
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
        self.heartbeat = try container.decode(String.self, forKey: .heartbeat)
        self.latitude = try container.decode(String.self, forKey: .latitude)
        self.longitude = try container.decode(String.self, forKey: .longitude)
        self.course = try container.decode(String.self, forKey: .course)
        self.speed = try container.decode(String.self, forKey: .speed)
        self.speedAccuracy = try container.decode(String.self, forKey: .speedAccuracy)
        self.courseAccuracy = try container.decode(String.self, forKey: .courseAccuracy)
        self.altitude = try container.decode(String.self, forKey: .altitude)
        self.altitudeAccuracy = try container.decode(String.self, forKey: .altitudeAccuracy)
        self.coordinateAccuracy = try container.decode(String.self, forKey: .coordinateAccuracy)
        self.heading = try container.decode(String.self, forKey: .heading)
        self.headingAccuracy = try container.decode(String.self, forKey: .headingAccuracy)
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
    
    // Computed Variable describes the sensor data, useful for testing
    //GAP: https://developer.apple.com/documentation/swift/string/init(describing:)-67ncf
    var description: String {
            return """
            SensorData:
            Timestamp: \(String(describing: timestamp))
            Accelerometer - X: \(String(describing: accelX)), Y: \(String(describing: accelY)), Z: \(String(describing: accelZ))
            Gyroscope - X: \(String(describing: gyroX)), Y: \(String(describing: gyroY)), Z: \(String(describing: gyroZ))
            Magnetometer - X: \(String(describing: magX)), Y: \(String(describing: magY)), Z: \(String(describing: magZ))
            Heartbeat - \(String(describing: heartbeat))
            """
        }
    
    init( timestamp: Double = Date().timeIntervalSince1970,accelX: String = "0.0", accelY: String = "0.0", accelZ: String = "0.0", gyroX: String = "0.0", gyroY: String = "0.0", gyroZ: String = "0.0",
          magX: String = "0.0", magY: String = "0.0", magZ: String = "0.0", heartbeat: String = "0", latitude: String = "0", longitude: String = "0" ,course: String = "0",speed: String = "0",
          speedAccuracy:String = "0", courseAccuracy: String = "0", altitude: String = "0", altitudeAccuracy: String = "0", coordinateAccuracy: String = "0", heading: String = "0",
          headingAccuracy: String = "0") {

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
        self.heartbeat = heartbeat
        self.latitude = latitude
        self.longitude = longitude
        self.course = course
        self.speed = speed
        self.speedAccuracy = speedAccuracy
        self.courseAccuracy = courseAccuracy
        self.altitude = altitude
        self.altitudeAccuracy = altitudeAccuracy
        self.coordinateAccuracy = coordinateAccuracy
        self.heading = heading
        self.headingAccuracy = headingAccuracy
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
        try container.encode(heartbeat, forKey: .heartbeat)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(course, forKey: .course)
        try container.encode(speed, forKey: .speed)
        try container.encode(speedAccuracy, forKey: .speedAccuracy)
        try container.encode(courseAccuracy, forKey: .courseAccuracy)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(altitudeAccuracy, forKey: .altitudeAccuracy)
        try container.encode(coordinateAccuracy, forKey: .coordinateAccuracy)
        try container.encode(heading, forKey: .heading)
        try container.encode(headingAccuracy, forKey: .headingAccuracy)
    }
}
