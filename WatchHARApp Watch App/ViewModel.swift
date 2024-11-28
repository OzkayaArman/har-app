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
import SwiftData

/*
 GAP: https://medium.com/appledeveloperacademy-ufpe/swift-how-to-use-coremotion-to-obtain-sensorial-data-20b1b73a948a
 GAP: https://developer.apple.com/documentation/coremotion/getting_processed_device-motion_data
 I have implemented startCollectingSensorData function, getMotion function, and publisher/private variables
 by following the example in the URL above and the developer documentation.
*/

class ViewModel: NSObject, ObservableObject, WKExtendedRuntimeSessionDelegate{

    private var context: ModelContext?
    @Published var isRecording = false
    
    //Holds sensor data
    @Published var sensorData: [ModelSensorData] = [
        ModelSensorData(
            timestamp: Date().timeIntervalSince1970,
            accelX: "0.0",
            accelY: "0.0",
            accelZ: "0.0",
            gyroX: "0.0",
            gyroY: "0.0",
            gyroZ: "0.0",
            magX: "0.0",
            magY: "0.0",
            magZ: "0.0"
        )
    ]
    
    
    
    //ViewModel class properties, marked with private for security best practices
    private var watchToIOSConnector: WatchToIOSConnector
    private var session: WKExtendedRuntimeSession?
    private let motionManager = CMMotionManager()
    
    // Properties to hold the sensor values
    private var userAcceleration: CMAcceleration = CMAcceleration()
    private var watchAttitude: CMAttitude = CMAttitude()
    private var magneticVector: CMCalibratedMagneticField = CMCalibratedMagneticField()
    

    //Constructor for the ViewModel which also initializes an instance of the watchToIOSConnector
    override init() {
            
            //Initialize watchToIOSConnector property, this property is an instance of WatchToIOSConnector class
            self.watchToIOSConnector = WatchToIOSConnector()
            super.init()
            
            /*
            The viewModel property of watchToIOSConnector instance is set to be self (an instance of ViewModel)
            enabling the connector to access viewModel's properties and methods.
            This is crucial for the phone application to control the watch application
             */
            self.watchToIOSConnector.viewModel = self
        }

    /*
     This function sets up an extended runtime session for background watch app execution
     Background execution enables sensor data collection regardless of wrist orientation
     This is required because Apple Watch OS goes to sleep when user wrist is down
     Sleeping apps can't collect data
     
     This function also sets up motion manager framework for sensor data collection
     */
    func startCollectingSensorData(){
        isRecording = true
        _ = Timer.scheduledTimer(timeInterval: 180, target: self, selector: #selector(timerFired), userInfo: nil, repeats: false)
        //Configure extended runtime session
        session = WKExtendedRuntimeSession()
        session?.delegate = self
        session?.start()
        
        // Sets the update interval of sensor read to 30 Hz
        motionManager.deviceMotionUpdateInterval = 1.0 / 30.0
        
        //Variable that indicate the frame of reference for attitude-related motion data
        //!! MAY NEED TO CHANGE
        let referenceFrame = CMAttitudeReferenceFrame.xTrueNorthZVertical
        
        //Check whether the reference frame is contained in the device and whether device motion is available
        if (CMMotionManager.availableAttitudeReferenceFrames().contains(referenceFrame) && motionManager.isDeviceMotionAvailable) {
    
                print("Starting to collect sensor data at 30 Hz")
                
                //Start reading sensor data
                motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main){ [weak self] (motion, error) in
                    guard let self = self else {return} // Avoids memory leaks
                    if let error = error{
                        print("Error: \(error.localizedDescription)")
                    }
                    
                    self.getMotion(motion: motion) //call getMotion function
                    
                }
        }

    } //End of startCollectingSensorData function
    
    
    func setContext(_ context: ModelContext) {
            self.context = context
            self.watchToIOSConnector.setContext(context)
        }
    
    @objc func timerFired(){
        stopCollectingSensorData()
        print("Stopping sensor data collection with timer")
    }
    
    //This method creates the struct of type SensorData so that the CSV file can be created
    private func getMotion(motion: CMDeviceMotion?){
        
        
        guard let context = context else {
                    print("Context is not set!")
                    return
                }
        
        //Unwrap the optional
        if let motion = motion {
            
            //Create the timestamp
            let timestamp = Date().timeIntervalSince1970
                        
            // Get user acceleration, gyroscope, and magnetometer data from sensors using coremoiton
            self.userAcceleration = motion.userAcceleration
            self.watchAttitude = motion.attitude
            self.magneticVector = motion.magneticField
            
            let newData = ModelSensorData( timestamp: timestamp, accelX: String(format: "%.5f", userAcceleration.x), accelY: String(format: "%.5f", userAcceleration.y),
                                          accelZ: String(format: "%.5f", userAcceleration.z), gyroX: String(format: "%.5f",  watchAttitude.pitch), gyroY: String(format: "%.5f",  watchAttitude.yaw),
                                          gyroZ: String(format: "%.5f",  watchAttitude.roll), magX: String(format: "%.5f", magneticVector.field.x), magY: String(format: "%.5f", magneticVector.field.y),
                                          magZ: String(format: "%.5f", magneticVector.field.z)
            )
                
            sensorData = [newData]
            context.insert(newData)
            //print(newData)
        }
    }
    
    
    //This function sends the data to IOS application
    func stopCollectingSensorData() {
        
        // Stop updating sensor data
        motionManager.stopDeviceMotionUpdates()
        isRecording = false
        
        //Send the sensor data to IOS application
        watchToIOSConnector.sendDataToIOS()
        
        //Stop the extended runtime
        session?.invalidate()
        session = nil
        
        //Reset the sensor data publisher for watch view
        sensorData = [
            ModelSensorData(
                timestamp: Date().timeIntervalSince1970,
                accelX: "0.0",
                accelY: "0.0",
                accelZ: "0.0",
                gyroX: "0.0",
                gyroY: "0.0",
                gyroZ: "0.0",
                magX: "0.0",
                magY: "0.0",
                magZ: "0.0"
            )
        ]
        
        //Reset the swift data context to prevent data spillage when a new activity recording session is started
        
        // Ensure the context is available
        guard let context = context else {
            print("Context is not set. Unable to fetch data.")
            return
        }
        do {
            // Fetch all `ModelSensorData` records using a FetchDescriptor
            let fetchDescriptor = FetchDescriptor<ModelSensorData>()
            let sensorDataArray = try context.fetch(fetchDescriptor)
            
            if sensorDataArray.isEmpty {
                print("No data found in the database to delete.")
                return
            }
            
            // Delete each fetched object
            for sensorData in sensorDataArray {
                context.delete(sensorData)
            }
            print("Deleted all sensor data")
            
        }catch {
            print("Error deleting data: \(error.localizedDescription)")
        }
    }
  
    //Functions necessary to implement extendedRuntimeSession
    //Functions taken from https://developer.apple.com/documentation/watchkit/using_extended_runtime_sessions
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
            print("Extended runtime session started successfully.")
        }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
            print("Extended runtime session will expire soon. Saving data and cleaning up.")
            stopCollectingSensorData()
            // I will add UI to alert the user that the session is ending
        }

    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
            print("Extended runtime session ended with reason: \(reason)")
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            stopCollectingSensorData()
        }
    

    
}
