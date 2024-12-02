import Foundation
import _SwiftData_SwiftUI
import SwiftUICore
import WatchConnectivity
import SwiftData

/*
 The code contained in this file was written by following a youtube tutorial
 the link for that tutorial is below
 GAP: https://www.youtube.com/watch?v=QzwHU0Xu_EY&t=949s
*/
class WatchToIOSConnector: NSObject, WCSessionDelegate, ObservableObject {
   
    
    private var context: ModelContext?
    
    
    //The object that initiates communication between a Watch app and its companion iOS app.
    var session: WCSession
    
    //Weak reference avoids memory leaks, when the ViewModel is deallocated, the viewModel property in WatchToIOSConnector automatically becomes nil.
    weak var viewModel: ViewModel?
    
    init(session: WCSession = .default){
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func setContext(_ context: ModelContext) {
            self.context = context
        }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    func sendDataToIOS() {
        // Ensure the context is available
        guard let context = context else {
            print("Context is not set. Unable to fetch data.")
            return
        }
 
        
        do {
            // Fetch all `ModelSensorData` records using a FetchDescriptor
            let fetchDescriptor = FetchDescriptor<ModelSensorData>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)] // Sort by timestamp in descending order
            )
            let sensorDataArray = try context.fetch(fetchDescriptor)
            print("Fetching context: \(context)")
            
            if sensorDataArray.isEmpty {
                print("No data found in the database to send.")
                return
            }
            
//            for data in sensorDataArray{
//                print("Acceleration")
//                print(data.accelX)
//            }

            // Convert the fetched data into JSON
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
//            do {
//                let jsonData = try encoder.encode(sensorDataArray)
//                if let jsonString = String(data: jsonData, encoding: .utf8) {
//                    print("Encoded JSON data: \(jsonString)")
//                }
//            } catch let EncodingError.invalidValue(value, context) {
//                print("Invalid value '\(value)' for encoding: \(context.debugDescription)")
//            } catch {
//                print("Unexpected encoding error: \(error.localizedDescription)")
//            }
            
            let jsonData = try encoder.encode(sensorDataArray)

            // Save the JSON data to a temporary file for transfer
            let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("SensorData.json")
            try jsonData.write(to: tempFileURL)

            // Transfer the file to the iPhone
            session.transferFile(tempFileURL, metadata: nil)
            print("Data sent to iPhone via file transfer: \(tempFileURL)")
        } catch {
            print("Error fetching or encoding sensor data: \(error.localizedDescription)")
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
