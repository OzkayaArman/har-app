
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
        print("File received from Watch with metadata: \(String(describing: file.metadata))")
        
        do {
            // Read the data from the received file URL
            let data = try Data(contentsOf: file.fileURL)
            
            // Attempt to decode the data as an array of SensorData
            let receivedData = try JSONDecoder().decode([SensorData].self, from: data)
            
            // Pass the decoded sensor data array to your ActivitiesViewModel
            DispatchQueue.main.async {
                // Method to handle received sensor data
                print("Sensor Data was added")
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
    }

    
    //This function is called from activity detail view and sends back the status of successful watch pairing
    func sendCommandToWatch(data: String) -> Bool{
        do{
            if(data == "Stop"){
                let data: [String: String] = [
                    "message": data,
                    "accelerometer" : "\(preferencesModel.accelerometer)",
                    "gyroscope" : "\(preferencesModel.gyroscope)",
                    "magnetometer" : "\(preferencesModel.magnetometer)",
                    "gps" : "\(preferencesModel.gps)",
                    "heartRateSensor" : "\(preferencesModel.heartRateSensor)",
                    "sessionDuration" : "\(preferencesModel.sessionDuration)"
                ]
                
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                
                let jsonData = try encoder.encode(data)
                
                let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("Command.json")
                try jsonData.write(to: tempFileURL)
                
                session.transferFile(tempFileURL, metadata: nil)
                print("Stop command sent to watch via file transfer: \(tempFileURL)")
            }else{
                let data: [String: String] = [
                    "message": data,
                    "accelerometer" : "\(preferencesModel.accelerometer)",
                    "gyroscope" : "\(preferencesModel.gyroscope)",
                    "magnetometer" : "\(preferencesModel.magnetometer)",
                    "gps" : "\(preferencesModel.gps)",
                    "heartRateSensor" : "\(preferencesModel.heartRateSensor)",
                    "sessionDuration" : "\(preferencesModel.sessionDuration)"
                ]
                
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                
                let jsonData = try encoder.encode(data)
                
                let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("Command.json")
                try jsonData.write(to: tempFileURL)
                
                session.transferFile(tempFileURL, metadata: nil)
                print("Start command sent to watch via file transfer: \(tempFileURL)")
            }
        }catch {
            print("Error fetching or encoding sensor data: \(error.localizedDescription)")
        }
            
            return true
    }
}
