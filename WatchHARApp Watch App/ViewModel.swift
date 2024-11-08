//
//  ViewModel.swift
//  WatchHARApp Watch App
//
//  Created by Arman Ozkaya on 03/11/2024.
//

import Foundation
import CoreMotion
import SwiftUI

struct SensorData{
    let accelerationX: Any
    let accelerationY: Any
    let accelerationZ: Any
    let rotationX: Any
    let rotationY: Any
    let rotationZ: Any
    let magnetometerX: Any
    let magnetometerY: Any
    let magnetometerZ: Any
}

class ViewModel: ObservableObject{
    @Published var accelerationValue: String?
    @Published var gyroscopeValue: String?
    @Published var magnetometerValue: String?
    //@Published var headingValue: String?
    
    
    @Published var isRecording = false
    var watchToIOSConnector: WatchToIOSConnector

    
    //Initialize an instance of cmmotionmanager responsible for handling sensor updates
    private let motionManager = CMMotionManager()
    
    init() {
            self.watchToIOSConnector = WatchToIOSConnector()
            self.watchToIOSConnector.viewModel = self // Pass ViewModel reference
        }

    // Properties to hold the sensor values
    private var userAcceleration: CMAcceleration = CMAcceleration()
    private var watchAttitude: CMAttitude = CMAttitude()
    private var magneticVector: CMCalibratedMagneticField = CMCalibratedMagneticField()
    

    
    func startCollectingSensorData(){
        isRecording = true
        
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
    
    func stopCollectingSensorData() {
        
        // Stop updating sensor data
        motionManager.stopDeviceMotionUpdates()
        isRecording = false
        accelerationValue = nil
        gyroscopeValue = nil
        magnetometerValue = nil
    }

    private func getMotion(motion: CMDeviceMotion?){
        //Unwrap the optional
        if let motion = motion {
            
            // Get user acceleration and gravity data
            self.userAcceleration = motion.userAcceleration
            self.watchAttitude = motion.attitude
            self.magneticVector = motion.magneticField
            
            // Update publishers with the new sensor data
            self.accelerationValue = """
            X: \(String(format: "%.5f", userAcceleration.x)), \n Y: \(String(format: "%.5f", userAcceleration.y)), \n Z: \(String(format: "%.5f", userAcceleration.z)) \n
            """

            self.gyroscopeValue = """
            X: \(String(format: "%.5f", watchAttitude.pitch)), \n Y: \(String(format: "%.5f", watchAttitude.yaw)), \n Z: \(String(format: "%.5f", watchAttitude.roll)) \n
            """

            self.magnetometerValue = """
            X: \(String(format: "%.5f", magneticVector.field.x)), \n Y: \(String(format: "%.5f", magneticVector.field.y)), \n Z: \(String(format: "%.5f", magneticVector.field.z)) \n
            """

            

            
            let sensorData = SensorData(
                accelerationX: Double(String(format: "%.5f", userAcceleration.x)) ?? userAcceleration.x,
                accelerationY: Double(String(format: "%.5f", userAcceleration.y)) ?? userAcceleration.y,
                accelerationZ: Double(String(format: "%.5f", userAcceleration.z)) ?? userAcceleration.z,
                rotationX: Double(String(format: "%.5f", watchAttitude.pitch)) ?? watchAttitude.pitch,
                rotationY: Double(String(format: "%.5f", watchAttitude.yaw)) ?? watchAttitude.yaw,
                rotationZ: Double(String(format: "%.5f", watchAttitude.roll)) ?? watchAttitude.roll,
                magnetometerX: Double(String(format: "%.5f", magneticVector.field.x)) ?? magneticVector.field.x,
                magnetometerY: Double(String(format: "%.5f", magneticVector.field.y)) ?? magneticVector.field.y,
                magnetometerZ: Double(String(format: "%.5f", magneticVector.field.z)) ?? magneticVector.field.z
            )

            
            
            watchToIOSConnector.sendDataToIOS(structData: sensorData)
        }
    }
    
    
    
}
