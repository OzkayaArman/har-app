import Foundation
import SwiftUICore
import WatchConnectivity

class WatchToIOSConnector: NSObject, WCSessionDelegate, ObservableObject {
    
    
    var session: WCSession
    @Published var startActivity : String?
    weak var viewModel: ViewModel?
    
    init(session: WCSession = .default){
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    func sendDataToIOS(structData: SensorData){
        if session.isReachable{
            print("The watch established a connection")
            print(structData)
            
            let data: [String: Any] = [
                "accelerometerX": structData.accelerationX,
                "accelerometerY": structData.accelerationY,
                "accelerometerZ": structData.accelerationZ,
                "gyroscopeX": structData.rotationX,
                "gyroscopeY": structData.rotationY,
                "gyroscopeZ": structData.rotationZ,
                "magnetometerX": structData.magnetometerX,
                "magnetometerY": structData.magnetometerY,
                "magnetometerZ": structData.magnetometerZ
            ]
            session.sendMessage(data, replyHandler: nil)
        }else {
            print("The watch couldn't find a connected iphone")
        }
    }
    
    //Receiving Messsage From Iphone
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let receivedMessage = message["message"] as? String {
                print("Message received from Iphone: \(receivedMessage)")
            DispatchQueue.main.async {
                if receivedMessage == "Start" {
                    self.viewModel?.startCollectingSensorData()
                } else if receivedMessage == "Stop" {
                    self.viewModel?.stopCollectingSensorData()
                }
            }

        }
    }
    
}
