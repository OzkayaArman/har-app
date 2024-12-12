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
import HealthKit
import CoreLocation

/*
 GAP: https://medium.com/appledeveloperacademy-ufpe/swift-how-to-use-coremotion-to-obtain-sensorial-data-20b1b73a948a
 GAP: https://developer.apple.com/documentation/coremotion/getting_processed_device-motion_data
 I have implemented startCollectingSensorData function, getMotion function, and publisher/private variables
 by following the example in the URL above and the developer documentations.
*/

class ViewModel: NSObject, ObservableObject, WKExtendedRuntimeSessionDelegate, CLLocationManagerDelegate{
    var sensorSpecifier: PreferencesData
    
    
    //context specifies where the app can commit data on device using Swift Data
    private var context: ModelContext?
    private var healthStore = HKHealthStore()
    var locationManager: CLLocationManager?
    let heartRateQuantity = HKUnit(from: "count/min")
    var heartRateQuery: HKAnchoredObjectQuery?
    
    //Publisher variable for watch view
    @Published var isRecording = false
    @Published var publishedHeartRate = 0
    @Published var latitude = 0.0
    @Published var longitude = 0.0
    @Published var course = 0.0
    @Published var speed = 0.0
    @Published var speedAccuracy = 0.0
    @Published var courseAccuracy = 0.0
    @Published var altitude = 0.0
    @Published var altitudeAccuracy = 0.0
    @Published var coordinateAccuracy = 0.0
    @Published var heading = 0.0
    @Published var headingAccuracy = 0.0
   
    
    //Holds sensor data
    @Published var sensorData: [ModelSensorData] = [ModelSensorData()]
    
    
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
        //This is a dummy initialization step, the real preferences are relayed when the user taps start activity button on the ios app.
        sensorSpecifier = PreferencesData(message: "Start", accelerometer: "true", gyroscope: "true", magnetometer: "true" , gps: "true", heartRateSensor: "true", sessionDuration: "180.0")
        
        //Initialize watchToIOSConnector property, this property is an instance of WatchToIOSConnector class
        self.watchToIOSConnector = WatchToIOSConnector()
        super.init()
            
        /*
        The viewModel property of watchToIOSConnector instance is set to be self (an instance of ViewModel)
        enabling the connector to access viewModel's properties and methods.
        This is crucial for the phone application to control the watch application
        */
        self.watchToIOSConnector.viewModel = self
        
        locationManager = CLLocationManager()
    }
    
    //Updates the preferences for which sensor will be utilized to collect data
    func setPreferences(preferencesIn: PreferencesData){
        self.sensorSpecifier = preferencesIn
        startCollectingSensorData()
    }
    
    //Swift data works with SwiftUI therefore, WatchView uses this method to inject in the context to the app's logic class
    func setContext(_ context: ModelContext) {
            self.context = context
            self.watchToIOSConnector.setContext(context)
        }
    

    /*
     This function sets up an extended runtime session for background watch app execution
     Background execution enables sensor data collection regardless of wrist orientation
     This is required because Apple Watch OS goes to sleep when user wrist is down
     Sleeping apps can't collect data
     
     This function also sets up motion manager framework for sensor data collection
     */
    func startCollectingSensorData(){
        //Toggle the variable to inform user the watch is collecting data through the watch UI
        isRecording = true
  
        //Configure extended runtime session
        session = WKExtendedRuntimeSession()
        session?.delegate = self
        session?.start()
        
        
        // Sets the update interval of sensor read to 30 Hz
        motionManager.deviceMotionUpdateInterval = 1.0 / 30.0
        
        //Variable that indicate the frame of reference for attitude-related motion data
        let referenceFrame = CMAttitudeReferenceFrame.xTrueNorthZVertical
        
        //Collect heart rate data if the preferences for collecting heart rate data was set
        if(sensorSpecifier.heartRateSensor == "true"){
            collectHeartRate()
        }
        
        //Collect GPS data if the preferences for collecting GPS data was set
        if(sensorSpecifier.gps == "true"){
            //Configure location collection
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.requestWhenInUseAuthorization()
        }
       
        
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            locationManager?.startUpdatingLocation()
            locationManager?.startUpdatingHeading()
        }
    }
    
    //GAP Below function locationManager was written by following the example https://dwirandyh.medium.com/deep-dive-into-core-location-in-ios-a-step-by-step-guide-to-requesting-and-utilizing-user-location-fe8325462ea9
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            print("No location updates received.")
            return
        }
        //Reduces location update to every 12 seconds (increases frequency of data collection for better results)
        locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager?.distanceFilter = kCLDistanceFilterNone
        locationManager?.activityType = .fitness
        print("Location updated: \(location)")
        print("Speed: \(location.speed), Course: \(location.course)")
        
        //Location Information
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        coordinateAccuracy = location.horizontalAccuracy
        
        //Speed and course information
        speed = location.speed
        speedAccuracy = location.speedAccuracy
        course = location.course
        courseAccuracy = location.courseAccuracy
        
        //Altituded information
        altitude = location.altitude
        altitudeAccuracy = location.verticalAccuracy
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading.trueHeading
        headingAccuracy = newHeading.headingAccuracy
    }
    
    //Code below taken from: GAP:https://medium.com/display-and-use-heart-rate-with-healthkit-on/display-and-use-heart-rate-with-healthkit-on-swiftui-for-watchos-2b26e29dc566
    //Begin Copied Code
    func collectHeartRate() {
        
        let healthKitType: Set = [
                HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]
        
        //Authorization Step
        healthStore.requestAuthorization(toShare: healthKitType, read: healthKitType){ success, error in
            if success {
                print("Authorization successful")
                self.fetchHeartRate(quantityTypeIdentifier: .heartRate)
            } else{
                print("Authorization failed: \(String(describing:error))")
            }
        }
    }
                          
                          
        func fetchHeartRate(quantityTypeIdentifier: HKQuantityTypeIdentifier){
            
            // We want data points from our current device
            let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
            
            // A query that returns changes to the HealthKit store, including a snapshot of new changes and continuous monitoring as a long-running query.
            let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
                query, samples, deletedObjects, queryAnchor, error in
                
                // A sample that represents a quantity, including the value and the units.
                guard let samples = samples as? [HKQuantitySample] else {
                    return
                }
                self.process(samples, type: quantityTypeIdentifier)
            }
            
            let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
                    
            query.updateHandler = updateHandler
            
            // Stores the query reference
            self.heartRateQuery = query
                    
            //Query execution
            healthStore.execute(query)
        }
    
    
        //Helper function for fetchHeartRate function
        private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
            // variable initialization
            var lastHeartRate = 0.0
            
            // cycle and value assignment
            for sample in samples {
                if type == .heartRate {
                    lastHeartRate = sample.quantity.doubleValue(for: heartRateQuantity)
                }
                DispatchQueue.main.async {
                    self.publishedHeartRate = Int(lastHeartRate)
                }
            }
        }
        
        //End copied Code

        
    
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
                        
            // Get user acceleration, gyroscope, and magnetometer data from sensors using coremotion
            // Check
            if(sensorSpecifier.accelerometer == "true"){
                self.userAcceleration = motion.userAcceleration
            }
            if(sensorSpecifier.gyroscope == "true"){
                self.watchAttitude = motion.attitude
            }
            
            if(sensorSpecifier.magnetometer == "true"){
                self.magneticVector = motion.magneticField
            }
            
            // Assign values conditionally
            let accelXin = (sensorSpecifier.accelerometer == "true") ? String(format: "%.5f", userAcceleration.x) : "N/A"
            let accelYin = (sensorSpecifier.accelerometer == "true") ? String(format: "%.5f", userAcceleration.y) : "N/A"
            let accelZin = (sensorSpecifier.accelerometer == "true") ? String(format: "%.5f", userAcceleration.z) : "N/A"

            let gyroXin = (sensorSpecifier.gyroscope == "true") ? String(format: "%.5f", watchAttitude.pitch) : "N/A"
            let gyroYin = (sensorSpecifier.gyroscope == "true") ? String(format: "%.5f", watchAttitude.yaw) : "N/A"
            let gyroZin = (sensorSpecifier.gyroscope == "true") ? String(format: "%.5f", watchAttitude.roll) : "N/A"

            let magXin = (sensorSpecifier.magnetometer == "true") ? String(format: "%.5f", magneticVector.field.x) : "N/A"
            let magYin = (sensorSpecifier.magnetometer == "true") ? String(format: "%.5f", magneticVector.field.y) : "N/A"
            let magZin = (sensorSpecifier.magnetometer == "true") ? String(format: "%.5f", magneticVector.field.z) : "N/A"
            
            let newData = ModelSensorData( timestamp: timestamp, accelX: accelXin, accelY: accelYin, accelZ: accelZin, gyroX: gyroXin, gyroY: gyroYin, gyroZ: gyroZin, magX: magXin, magY: magYin,magZ: magZin,
                                           heartbeat: "\(publishedHeartRate)",latitude: "\(latitude)", longitude: "\(longitude)", course: "\(course)", speed:"\(speed)", speedAccuracy: "\(speedAccuracy)",
                                           courseAccuracy: "\(courseAccuracy)", altitude: "\(altitude)", altitudeAccuracy: "\(altitudeAccuracy)",coordinateAccuracy: "\(coordinateAccuracy)", heading: "\(heading)",
                                           headingAccuracy: "\(headingAccuracy)")

            sensorData = [newData]
            context.insert(newData)
        }
    }
    
    //This function sends the data to IOS application
    func stopCollectingSensorData() {
        //Send the sensor data to IOS application
        watchToIOSConnector.sendDataToIOS()
        
        //Unwrap optional and stop heart rate data collection
        if let query = heartRateQuery {
            healthStore.stop(query)
            heartRateQuery = nil
        }
        // Stop updating sensor data
        motionManager.stopDeviceMotionUpdates()
        locationManager?.stopUpdatingLocation()
        locationManager?.stopUpdatingHeading()
        
        isRecording = false
        
        
        //Stop the extended runtime
        session?.invalidate()
        session = nil
        
        //Reset the sensor data publisher for watch view
        publishedHeartRate = 0;
        
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
                magZ: "0.0",
                heartbeat: "0",
                latitude: "0.0",
                longitude: "0.0",
                course: "0.0",
                speed: "0.0",
                speedAccuracy: "0.0",
                courseAccuracy: "0.0",
                altitude: "0.0",
                altitudeAccuracy: "0.0",
                coordinateAccuracy: "0.0",
                heading: "0.0",
                headingAccuracy: "0.0"
                
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
