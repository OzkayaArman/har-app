//
//  ViewModel.swift
//  WatchHARApp Watch App
//
//  Created by Arman Ozkaya on 03/11/2024.
//

import Foundation
import CoreMotion
import SwiftUI

class ViewModel: ObservableObject{
    @Published var accelerationValue: String?
    @Published var gyroscopeValue: String?
    @Published var magnetometerValue: String?
    //@Published var headingValue: String?
    
    @Published var isRecording = false
    
    //Initialize an instance of cmmotionmanager responsible for handling sensor updates
    private let motionManager = CMMotionManager()
    
    

    // Properties to hold the sensor values
    private var userAcceleration: CMAcceleration = CMAcceleration()
    private var rotationRate: CMRotationRate = CMRotationRate()
    private var magneticVector: CMCalibratedMagneticField = CMCalibratedMagneticField()
    
  
    
    func startCollectingSensorData(){
        isRecording = true
        
        // Sets the update interval to 30 Hz
        motionManager.deviceMotionUpdateInterval = 1.0 / 30.0

        print("in call")
        
        let referenceFrame = CMAttitudeReferenceFrame.xMagneticNorthZVertical
        if (CMMotionManager.availableAttitudeReferenceFrames().contains(referenceFrame) && motionManager.isDeviceMotionAvailable) {
    
                print("Starting to collect sensor data at 30 Hz")
                
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
            self.rotationRate = motion.rotationRate
            self.magneticVector = motion.magneticField
            
            // Update publishers with the new sensor data
            self.accelerationValue = "X: \(userAcceleration.x), \n Y: \(userAcceleration.y), \n Z: \(userAcceleration.z)"
            self.gyroscopeValue = "X: \(rotationRate.x), \n Y: \(rotationRate.y), \n Z: \(rotationRate.z)"
            self.magnetometerValue = "X: \(magneticVector.field.x), \n Y: \(magneticVector.field.y), \n Z: \(magneticVector.field.z)"
            
            let sensorData: [String: Any] = [
                "acceleration": [
                    "x": userAcceleration.x,
                    "y": userAcceleration.y,
                    "z": userAcceleration.z
                ],
                "rotationRate": [
                    "x": rotationRate.x,
                    "y": rotationRate.y,
                    "z": rotationRate.z
                ],
                "magneticField": [
                    "x": magneticVector.field.x,
                    "y": magneticVector.field.y,
                    "z": magneticVector.field.z
                ]
            ]

            
            //watchConnector.sendData(sensorData: sensorData)
        }
    }
    
    
    
}
