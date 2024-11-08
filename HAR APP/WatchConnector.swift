
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
               // Format the accelerometer data
               let accelerationString = """
               X: \(message["accelerometerX"] as? Double ?? 0), \n Y: \(message["accelerometerY"] as? Double ?? 0), \n Z: \(message["accelerometerZ"] as? Double ?? 0) \n
               """
               self.activityViewModel?.accelerationValue = accelerationString
               print("Acceleration: \(accelerationString)")

               // Format the gyroscope data
               let gyroscopeString = """
               X: \(message["gyroscopeX"] as? Double ?? 0), \n Y: \(message["gyroscopeY"] as? Double ?? 0), \n Z: \(message["gyroscopeZ"] as? Double ?? 0) \n
               """
               self.activityViewModel?.gyroscopeValue = gyroscopeString
               print("Gyroscope: \(gyroscopeString)")

               // Format the magnetometer data
               let magnetometerString = """
               X: \(message["magnetometerX"] as? Double ?? 0), \n Y: \(message["magnetometerY"] as? Double ?? 0), \n Z: \(message["magnetometerZ"] as? Double ?? 0) \n
               """
               self.activityViewModel?.magnetometerValue = magnetometerString
               print("Magnetometer: \(magnetometerString)")
           }
    }

    
    //This function is called from activity detail view
    func sendCommandToWatch(data: String){
        if session.isReachable{
            print("Iphone established a connection")
            
            let data: [String: Any] = [
                "message": data
            ]
            session.sendMessage(data, replyHandler: nil)
        }else {
            print("The watch couldn't find a connected iphone")
        }
    }
}
