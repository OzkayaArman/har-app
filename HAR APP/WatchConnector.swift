
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
    
    /*
    Weak reference avoids memory leaks, when the ActivitiesViewModel is deallocated, the activity
    viewModel property in WatchConnector automatically becomes nil
    */
    weak var activityViewModel: ActivitiesViewModel?
    
    //Constructor
    init(session: WCSession = .default){
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
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
        if session.isReachable{
            print("Iphone established a connection")
            
            let data: [String: Any] = [
                "message": data
            ]
            session.sendMessage(data, replyHandler: nil)
            return true
        }else {
            print("The iphone couldn't find a connected watch")
            return false
        }
    }
}
