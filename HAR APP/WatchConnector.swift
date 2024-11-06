
import Foundation
import WatchConnectivity

//Establish Connection Between Iphone And Apple Watch
class WatchConnector: NSObject, WCSessionDelegate{
    
    
    var session: WCSession
    
    override init() {
            if WCSession.isSupported() {
                self.session = WCSession.default
                super.init()
                session.delegate = self
                session.activate()
            } else {
                self.session = WCSession.default
                super.init()
            }
    }
    
    // Method to send start activity command
    func sendStartActivity() {
        if session.isPaired && session.isWatchAppInstalled {
            let message = ["command": "startActivity"]
            session.sendMessage(message, replyHandler: nil) { error in
                print("Error sending message: \(error.localizedDescription)")
            }
        } else {
            print("Watch is not paired or app is not installed")
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
            DispatchQueue.main.async {
                print("Received message: \(message)")
                // Process received sensor data
                if let acceleration = message["acceleration"] as? [String: Double],
                   let rotationRate = message["rotationRate"] as? [String: Double],
                   let magneticField = message["magneticField"] as? [String: Double],
                   let heading = message["heading"] as? Double {
                    // Handle the data as needed
                    print("Acceleration: \(acceleration)")
                    print("Rotation Rate: \(rotationRate)")
                    print("Magnetic Field: \(magneticField)")
                    print("Heading: \(heading)")
                } else {
                    print("Failed to parse sensor data from message")
                }
            }
        }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    
}
