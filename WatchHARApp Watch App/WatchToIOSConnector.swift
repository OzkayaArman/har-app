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
    
    func sendDataToIOS(structData: [SensorData]){
        print(structData.description)
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent("SensorData-\(Date().timeIntervalSince1970).json")
        
        do {
            // Encode data and write to file
            let jsonData = try JSONEncoder().encode(structData)
            try jsonData.write(to: fileURL)
                
            // Transfer the file to the iPhone
            session.transferFile(fileURL, metadata: ["fileType": "sensorData"])
            print("File transfer initiated for \(fileURL)")
        } catch {
                print("Failed to write sensor data to file with error: \(error.localizedDescription)")
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
