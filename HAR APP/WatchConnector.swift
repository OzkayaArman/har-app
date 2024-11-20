
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
            print("Received sensor data array: \(receivedData)")
            
            // Pass the decoded sensor data array to your ActivitiesViewModel
            DispatchQueue.main.async {
                // Assuming your ActivitiesViewModel has a method to handle received sensor data
                self.activityViewModel?.sensorData.append(contentsOf: receivedData)
                self.activityViewModel?.addSensorData()
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
            print("The iphone couldn't find a connected iphone")
            return false
        }
    }
}
