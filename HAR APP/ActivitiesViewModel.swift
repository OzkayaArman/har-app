//
//  ActivitiesViewModel.swift
//  HAR APP
//
//  Created by Arman Ozkaya on 02/11/2024.
//

import SwiftUI
import CoreMotion
import CoreLocation
import CoreTransferable
import SwiftCSVEncoder
import UniformTypeIdentifiers

struct SensorData: Codable {
    var timestamp: Double
    var accelX: String
    var accelY: String
    var accelZ: String
    var gyroX: String
    var gyroY: String
    var gyroZ: String
    var magX: String
    var magY: String
    var magZ: String
}


final class ActivitiesViewModel: ObservableObject {
    @Published var accelerationValueX: String?
    @Published var accelerationValueY: String?
    @Published var accelerationValueZ: String?
    @Published var gyroscopeValueX: String?
    @Published var gyroscopeValueY: String?
    @Published var gyroscopeValueZ: String?
    @Published var magnetometerValueX: String?
    @Published var magnetometerValueY: String?
    @Published var magnetometerValueZ: String?
    
    @Published var firstName: String?
    @Published var lastName: String?
    @Published var email: String?
    
    
    @Published var sensorData: [SensorData] = []
    
    
    var isShowingDetailView = false
    var watchConnector: WatchConnector
    
    //These columns are refactored here for clean code, they are columns of MainPageView's grid view
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible())]
    
    init() {
        self.watchConnector = WatchConnector()
        self.watchConnector.activityViewModel = self // Pass activityViewModel reference
        loadUserData()
    }

    //This method creates the struct of type SensorData so that the CSV file can be created
    func addSensorData() {
        print("Sensor Data was added")
        let timestamp = Date().timeIntervalSince1970
        let newData = SensorData(timestamp: timestamp, accelX: accelerationValueX ?? "", accelY: accelerationValueY ?? "", accelZ: accelerationValueZ ?? "", gyroX: gyroscopeValueX ?? "",
                                 gyroY: gyroscopeValueY ?? "", gyroZ: gyroscopeValueZ ?? "", magX: magnetometerValueX ?? "", magY: magnetometerValueY ?? "", magZ: magnetometerValueZ ?? "")
            
        sensorData.append(newData)
    }
    
    //This function is called upon an activity data collection session finish to clear the published struct
    //Aim is to get the struct ready for further data collection
    func cleanSensorData() {
        sensorData.removeAll()
    }
    
        
        
//    // Method to generate CSV file from the data
//    func exportDataToCSV() -> CSVFile {
//        return CSVFile(data: sensorData, activityName: "ActivityData")
//    }
    
    func loadUserData() {
        guard let appleUserData = UserDefaults.standard.data(forKey: "appleUser"),
            let appleUser = try? JSONDecoder().decode(AppleUser.self, from: appleUserData) else { return }
        firstName = appleUser.firstName
        lastName = appleUser.lastName
        email = appleUser.email

    }
    
}




///GAP: https://swiftpackageindex.com/scottmatthewman/swiftcsvencoder/0.2.0/documentation/swiftcsvencoder/incorporatingcsv
//The following code for creating a csv file was obtained from the apple developer documentation above
// Begin Copied Code

//This struct represents the exported data
//The idea of CSVFile having to conform to FileDocument, configuration and filewrapper functions was obtained from ChatGPT upon failure to
//implement .fileexporter modifier in ActivityDetailView

struct CSVFile: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }
    var data: [SensorData]
    var activityName: String
    var userName: String
    
    init(configuration: ReadConfiguration) throws {
            self.data = []
            self.activityName = ""
            self.userName = ""
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
            let csvData = self.csvData().data(using: .utf8) ?? Data()
            return FileWrapper(regularFileWithContents: csvData)
    }
    

    //Initializer to create the csvfile struct
    init(data: [SensorData], activityName: String, userName: String) {
        self.data = data
        self.activityName = activityName
        self.userName = userName
    }
}
    
    
    extension CSVFile{
        func csvData() -> String {
            let table = CSVTable<SensorData>(
                columns: [
                    CSVColumn("Timestamp", \.timestamp),
                    CSVColumn("AccelX", \.accelX),
                    CSVColumn("AccelY", \.accelY),
                    CSVColumn("AccelZ", \.accelZ),
                    CSVColumn("GyroX", \.gyroX),
                    CSVColumn("GyroY", \.gyroY),
                    CSVColumn("GyroZ", \.gyroZ),
                    CSVColumn("MagX", \.magX),
                    CSVColumn("MagY", \.magY),
                    CSVColumn("MagZ", \.magZ)
                ],
                configuration: CSVEncoderConfiguration(dateEncodingStrategy: .iso8601)

            )
            return table.export(rows: data)
        }
    }
    

    
    //This extension makes the object conform to transferable to manage interaction with OS
    extension CSVFile: Transferable {
        static var transferRepresentation: some TransferRepresentation {
            DataRepresentation(exportedContentType: UTType.commaSeparatedText) { file in
                Data(file.csvData().utf8)
            }
        }
    }

// End Copied Code

