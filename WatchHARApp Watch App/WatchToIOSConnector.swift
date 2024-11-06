import Foundation
import WatchConnectivity

class WatchToIOSConnector: NSObject, WCSessionDelegate, ObservableObject {
    
    
    var session: WCSession
    
    init(session: WCSession = .default){
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    func sendDataToIOS(data: String){
        if session.isReachable{
            print("The watch established a connection")
            let data: [String: Any] = [
                "Test Connection": data
            ]
            session.sendMessage(data, replyHandler: nil)
        }else {
            print("The watch couldn't find a connected iphone")
        }
    }
    
}
