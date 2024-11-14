
import Foundation
import WatchConnectivity
import SwiftUICore

class WatchConnector: NSObject, WCSessionDelegate, ObservableObject{
    
    
    var session: WCSession
    weak var activityViewModel: ActivitiesViewModel?
    
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
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Message received from Watch: \(message)")
        
        DispatchQueue.main.async {
            
            // Pass accelerometer data to the ActivitiesViewModel
            let accelerationStringX = "\(message["accelerometerX"] as? Double ?? 0)"
            let accelerationStringY = "\(message["accelerometerY"] as? Double ?? 0)"
            let accelerationStringZ = "\(message["accelerometerZ"] as? Double ?? 0)"
               
            
            self.activityViewModel?.accelerationValueX = accelerationStringX
            self.activityViewModel?.accelerationValueY = accelerationStringY
            self.activityViewModel?.accelerationValueZ = accelerationStringZ
            
            print("Acceleration:")
            print(accelerationStringX)
            print(accelerationStringY)
            print(accelerationStringZ)
            
            // Pass groscope data to the ActivitiesViewModel
            let gyroscopeStringX = "\(message["gyroscopeX"] as? Double ?? 0)"
            let gyroscopeStringY = "\(message["gyroscopeY"] as? Double ?? 0)"
            let gyroscopeStringZ = "\(message["gyroscopeZ"] as? Double ?? 0)"
            
            self.activityViewModel?.gyroscopeValueX = gyroscopeStringX
            self.activityViewModel?.gyroscopeValueY = gyroscopeStringY
            self.activityViewModel?.gyroscopeValueZ = gyroscopeStringZ
            
               
            // Pass magnotemeter data to the ActivitiesViewModel
            let magnetometerStringX = " \(message["magnetometerX"] as? Double ?? 0)"
            let magnetometerStringY = " \(message["magnetometerY"] as? Double ?? 0)"
            let magnetometerStringZ = " \(message["magnetometerZ"] as? Double ?? 0)"
            
            self.activityViewModel?.magnetometerValueX = magnetometerStringX
            self.activityViewModel?.magnetometerValueY = magnetometerStringY
            self.activityViewModel?.magnetometerValueZ = magnetometerStringZ
            
            self.activityViewModel?.addSensorData()
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
