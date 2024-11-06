
import Foundation
import WatchConnectivity
import SwiftUI

class WatchToIOSConnector: NSObject, WCSessionDelegate, ObservableObject{
    var session: WCSession
    @StateObject var viewModel = ViewModel()

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
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if let error = error {
                    print("Session activation failed with error: \(error.localizedDescription)")
        } else {
            print("Session activated with state: \(activationState.rawValue)")
        }
    }
    

    
    
    //For sending data to the ios app
    func sendData(sensorData: [String: Any]) {
        //Check if the IOS app is reachable
        if session.isReachable {
            session.sendMessage(sensorData, replyHandler: nil) { error in
                print("Error sending message: \(error.localizedDescription)")
            }
        } else {
            print("iPhone is not reachable")
        }
    }
    
    // Handle incoming messages
        func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
            DispatchQueue.main.async {
                if let command = message["command"] as? String {
                    if command == "startActivity" {
                        self.viewModel.startCollectingSensorData()
                    }
                }
            }
        }
}
    

    

