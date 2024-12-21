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
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
            return
        }
    }
    
    func sendConfirmationBack(){
        do {
            // Convert the message into JSON
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let confirmation: [String: String] = ["status": "commandReceived"]
            let jsonData = try encoder.encode(confirmation)

            // Save the JSON data to a temporary file for transfer
            let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("SensorData.json")
            try jsonData.write(to: tempFileURL)
            
            // Transfer the file to the iPhone
            session.transferFile(tempFileURL, metadata: ["status":"commandReceived"])
            print("Confirmation sent to iPhone via file transfer: \(tempFileURL)")
            
        } catch {
            print("Error sending confirmation back: \(error.localizedDescription)")
        }
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
            
            if sensorDataArray.isEmpty {
                print("No data found in the database to send.")
                return
            }

            // Convert the fetched data into JSON
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            let jsonData = try encoder.encode(sensorDataArray)

            // Save the JSON data to a temporary file for transfer
            let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("SensorData.json")
            try jsonData.write(to: tempFileURL)
            

            // Transfer the file to the iPhone
           session.transferFile(tempFileURL, metadata: ["status":"fileReceived"])
            print("Data sent to iPhone via file transfer: \(tempFileURL)")
            
        } catch {
            print("Error fetching or encoding sensor data: \(error.localizedDescription)")
        }
    }



    //Receiving Messsage From Iphone
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print("File received from Iphone with metadata: \(String(describing: file.metadata))")
        
        do {
            // Read the data from the received file URL
            let data = try Data(contentsOf: file.fileURL)
            
            // Attempt to decode the data as an array of SensorData
            let receivedData = try JSONDecoder().decode(PreferencesData.self, from: data)
            
            // Pass the decoded sensor data array to the ViewModel
            DispatchQueue.main.async {
                if(receivedData.message == "Start"){
                    // Method to handle received sensor data
                    print("Preferences data was received")
                    self.sendConfirmationBack()
                    self.viewModel?.setPreferences(preferencesIn: receivedData)
                    
                }else{
                    self.sendConfirmationBack()
                    self.viewModel?.stopCollectingSensorData()
                }
            }
            
        } catch {
            print("Failed to decode sensor data from received file with error: \(error.localizedDescription)")
        }
    }
    
}
