
import Foundation
import WatchConnectivity
import SwiftUICore

/*
 The code contained in this file was written by following a youtube tutorial
 the link for that tutorial is below
 GAP: https://www.youtube.com/watch?v=QzwHU0Xu_EY&t=949s
*/
class WatchConnector: NSObject, WCSessionDelegate, ObservableObject{
    
    //The object that initiates communication between an IOS app and its companion watch os app.
    var session: WCSession
    
    var preferencesModel: Preferences
    
    /*
    Weak reference avoids memory leaks, when the ActivitiesViewModel is deallocated, the activity
    viewModel property in WatchConnector automatically becomes nil
    */
    weak var activityViewModel: ActivitiesViewModel?
    
    //Constructor
    init(session: WCSession = .default, preferencesModel: Preferences){
        self.session = session
        self.preferencesModel = preferencesModel
        super.init()
        session.delegate = self
        session.activate()
        print("Constructor")
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
            return
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
    // Receiving Message From Apple Watch
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        guard let metadataDict = file.metadata as? [String: String] else {
            print("Error in receiving message")
            return
        }
        print("Received message: metadata: \(metadataDict)")
        
        switch metadataDict["status"] {
            //If the iphone is receiving senssor data
            case "fileReceived":
                do {
                    // Read the data from the received file URL
                    let data = try Data(contentsOf: file.fileURL)
                    
                    // Convert data to a string for debugging
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Raw JSON Data:\n\(jsonString)")
                    } else {
                        print("Failed to convert data to string.")
                    }
                    // Attempt to decode the data as an array of SensorData
                    let receivedData = try JSONDecoder().decode([SensorData].self, from: data)
                    
                    // Pass the decoded sensor data array to your ActivitiesViewModel
                    DispatchQueue.main.async {
                        // Method to handle received sensor data
                        for data in receivedData{
                            self.activityViewModel!.addSensorData(accelX: data.accelX, accelY: data.accelY, accelZ: data.accelZ, gyroX: data.gyroX, gyroY: data.gyroY, gyroZ: data.gyroZ, magX: data.magX,
                                                              magY: data.magY, magZ: data.magZ, heartbeat: data.heartbeat, latitude: data.latitude, longitude: data.longitude, course: data.course,
                                                              speed: data.speed, speedAccuracy: data.speedAccuracy, courseAccuracy: data.courseAccuracy, altitude: data.altitude, altitudeAccuracy: data.altitudeAccuracy,
                                                              coordinateAccuracy: data.coordinateAccuracy, heading: data.heading, headingAccuracy: data.headingAccuracy)
                        }
                    self.activityViewModel?.exportReady = true
                    }
                } catch {
                    print("Failed to decode sensor data from received file with error: \(error.localizedDescription)")
                }
            //If the iphone is receiving confirmation that start/stop command was received by the watch
            case "commandReceived":
                DispatchQueue.main.async {
                    //This triggers the on change closure in ActivityDetailView
                    self.activityViewModel?.receivedConfirmation = true
                }
            default:
                print("Received unknown case")
        }
    }
    
    //This function is called from activity detail view and sends back the status of successful watch pairing
    func sendCommandToWatch(data: String) -> Bool{
            do{
                //If sending stop command
                if(data == "Stop"){
                    let data: [String: String] = [
                        "message": data,
                        "accelerometer" : "\(preferencesModel.accelerometer)",
                        "gyroscope" : "\(preferencesModel.gyroscope)",
                        "magnetometer" : "\(preferencesModel.magnetometer)",
                        "gps" : "\(preferencesModel.gps)",
                        "heartRateSensor" : "\(preferencesModel.heartRateSensor)",
                        "sessionDuration" : "\(preferencesModel.sessionDuration)",
                        "samplingRate" : "\(preferencesModel.samplingRate)"
                    ]
                    
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    
                    let jsonData = try encoder.encode(data)
                    
                    let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("Command.json")
                    try jsonData.write(to: tempFileURL)
                    
                    session.transferFile(tempFileURL, metadata: nil)
                    
                    print("Stop command sent to watch via file transfer: \(tempFileURL)")
                    return true
                }else{
                    if (session.isReachable) {
                        //If sending start command
                        let data: [String: String] = [
                            "message": data,
                            "accelerometer" : "\(preferencesModel.accelerometer)",
                            "gyroscope" : "\(preferencesModel.gyroscope)",
                            "magnetometer" : "\(preferencesModel.magnetometer)",
                            "gps" : "\(preferencesModel.gps)",
                            "heartRateSensor" : "\(preferencesModel.heartRateSensor)",
                            "sessionDuration" : "\(preferencesModel.sessionDuration)",
                            "samplingRate" : "\(preferencesModel.samplingRate)"
                        ]
                        
                        let encoder = JSONEncoder()
                        encoder.outputFormatting = .prettyPrinted
                        
                        let jsonData = try encoder.encode(data)
                        
                        let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("Command.json")
                        try jsonData.write(to: tempFileURL)
                        
                        session.transferFile(tempFileURL, metadata: nil)
                        print("Start command sent to watch via file transfer: \(tempFileURL)")
                        return true
                    }else{
                            return false
                        }
                }
            }catch {
                print("Error fetching or encoding sensor data: \(error.localizedDescription)")
                return true
            }
    }
}
