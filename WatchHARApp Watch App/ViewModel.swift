//
//  ViewModel.swift
//  WatchHARApp Watch App
//
//  Created by Arman Ozkaya on 03/11/2024.
//

import Foundation
import CoreMotion
import SwiftUI
import WatchKit

struct SensorData: Codable{
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
    
    var description: String {
            return """
            SensorData:
            Timestamp: \(timestamp)
            Accelerometer - X: \(accelX), Y: \(accelY), Z: \(accelZ)
            Gyroscope - X: \(gyroX), Y: \(gyroY), Z: \(gyroZ)
            Magnetometer - X: \(magX), Y: \(magY), Z: \(magZ)
            """
        }
}
//GAP: https://medium.com/appledeveloperacademy-ufpe/swift-how-to-use-coremotion-to-obtain-sensorial-data-20b1b73a948a
// I have implemented startCollectingSensorData function, getMotion function, and publisher/private variables
// by following the example in the URL above.

class ViewModel: NSObject, ObservableObject, WKExtendedRuntimeSessionDelegate{
    
    @Published var accelerationValueX: String?
    @Published var accelerationValueY: String?
    @Published var accelerationValueZ: String?
    @Published var gyroscopeValueX: String?
    @Published var gyroscopeValueY: String?
    @Published var gyroscopeValueZ: String?
    @Published var magnetometerValueX: String?
    @Published var magnetometerValueY: String?
    @Published var magnetometerValueZ: String?
    
    @Published var isRecording = false
    @Published var isExtended = false
   
    
    @Published var sensorData: [SensorData] = []
    
    
    
    var watchToIOSConnector: WatchToIOSConnector
    private var session: WKExtendedRuntimeSession?
    private let motionManager = CMMotionManager()

    //Constructor for the ViewModel which also initialized the watchToIOSConnector
    override init() {
            //Initialize watchToIOSConnector property, this property is an instance of WatchToIOSConnector class
            self.watchToIOSConnector = WatchToIOSConnector()
            super.init()
            // The viewModel property of watchToIOSConnector instance is set to be self, enabling the connector to access viewModel's properties and methods
            //This is crucial for the phone application to control the watch application
            self.watchToIOSConnector.viewModel = self
        }

    // Properties to hold the sensor values
    private var userAcceleration: CMAcceleration = CMAcceleration()
    private var watchAttitude: CMAttitude = CMAttitude()
    private var magneticVector: CMCalibratedMagneticField = CMCalibratedMagneticField()
    

    
    func startCollectingSensorData(){
        isRecording = true
        
        //Configure extended runtime session instance to enable the watch app to collect data after the user stops directly interacting with the app (Example: User Wrist Down)
        session = WKExtendedRuntimeSession()
        session?.delegate = self
        session?.start()
        
        // Sets the update interval to 30 Hz
        motionManager.deviceMotionUpdateInterval = 1.0 / 30.0
        
        let referenceFrame = CMAttitudeReferenceFrame.xMagneticNorthZVertical
        if (CMMotionManager.availableAttitudeReferenceFrames().contains(referenceFrame) && motionManager.isDeviceMotionAvailable) {
    
                print("Starting to collect sensor data at 30 Hz")
                
                
                //GAP: https://developer.apple.com/documentation/coremotion/getting_processed_device-motion_data
                //Start updating the accelerometer sensor data
                motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main){ [weak self] (motion, error) in
                    guard let self = self else {return}
                    
                    if let error = error{
                        print("Error: \(error.localizedDescription)")
                    }
                    
                    self.getMotion(motion: motion)
                    
                }

            
        }

    } //End of startCollectingSensorData
    
    //This method creates the struct of type SensorData so that the CSV file can be created
    func addSensorData(){
        let timestamp = Date().timeIntervalSince1970
        let newData = SensorData(timestamp: timestamp, accelX: accelerationValueX ?? "", accelY: accelerationValueY ?? "", accelZ: accelerationValueZ ?? "", gyroX: gyroscopeValueX ?? "",
                                 gyroY: gyroscopeValueY ?? "", gyroZ: gyroscopeValueZ ?? "", magX: magnetometerValueX ?? "", magY: magnetometerValueY ?? "", magZ: magnetometerValueZ ?? "")
            
        sensorData.append(newData)
        print(newData)
        print("Sensor Data was added on the watch")
    }
    
    
    func stopCollectingSensorData() {
        
        // Stop updating sensor data
        motionManager.stopDeviceMotionUpdates()
        isRecording = false
        
        //Clean publisher variables
        accelerationValueX = nil
        accelerationValueY = nil
        accelerationValueZ = nil

        gyroscopeValueX = nil
        gyroscopeValueY = nil
        gyroscopeValueZ = nil

        magnetometerValueX = nil
        magnetometerValueY = nil
        magnetometerValueZ = nil
        
        watchToIOSConnector.sendDataToIOS(structData: sensorData)
        
        //Stop the extended runtime
        session?.invalidate()
        session = nil
        
    }
    
  
    
    private func getMotion(motion: CMDeviceMotion?){
        //Unwrap the optional
        if let motion = motion {
            
            // Get user acceleration, gyroscope, and magnetometer data
            self.userAcceleration = motion.userAcceleration
            self.watchAttitude = motion.attitude
            self.magneticVector = motion.magneticField
            
            // Update publishers with the new sensor data
            self.accelerationValueX = String(format: "%.5f", userAcceleration.x)
            self.accelerationValueY = String(format: "%.5f", userAcceleration.y)
            self.accelerationValueZ = String(format: "%.5f", userAcceleration.z)
            
            self.gyroscopeValueX = String(format: "%.5f",  watchAttitude.pitch)
            self.gyroscopeValueY = String(format: "%.5f",  watchAttitude.yaw)
            self.gyroscopeValueZ = String(format: "%.5f",  watchAttitude.roll)
            
            self.magnetometerValueX = String(format: "%.5f", magneticVector.field.x)
            self.magnetometerValueY = String(format: "%.5f", magneticVector.field.y)
            self.magnetometerValueZ = String(format: "%.5f", magneticVector.field.z)
            
            //Update the array that stores each snapshot of sensor data: 3Ohz == 30 array elements per second
            addSensorData()
            
//            let sensorData = SensorData(
//                timestamp: <>,
//                ccelX: Double(String(format: "%.5f", userAcceleration.x)) ?? userAcceleration.x,
//                accelY: Double(String(format: "%.5f", userAcceleration.y)) ?? userAcceleration.y,
//                accelZ: Double(String(format: "%.5f", userAcceleration.z)) ?? userAcceleration.z,
//                gyroX: Double(String(format: "%.5f", watchAttitude.pitch)) ?? watchAttitude.pitch,
//                gyroY: Double(String(format: "%.5f", watchAttitude.yaw)) ?? watchAttitude.yaw,
//                gyroZ: Double(String(format: "%.5f", watchAttitude.roll)) ?? watchAttitude.roll,
//                magX: Double(String(format: "%.5f", magneticVector.field.x)) ?? magneticVector.field.x,
//                magY: Double(String(format: "%.5f", magneticVector.field.y)) ?? magneticVector.field.y,
//                magZ: Double(String(format: "%.5f", magneticVector.field.z)) ?? magneticVector.field.z
//            )
            
  //          watchToIOSConnector.sendDataToIOS(structData: sensorData)
        }
    }
    
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
            print("Extended runtime session started successfully.")
            isExtended = true
        }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
            print("Extended runtime session will expire soon. Saving data and cleaning up.")
            stopCollectingSensorData()
            // I will ad UI to alert the user that the session is ending
        }

    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
            print("Extended runtime session ended with reason: \(reason)")
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            stopCollectingSensorData()
        }
    

    
}
