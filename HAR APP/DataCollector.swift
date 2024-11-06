//
//  DataCollector.swift
//  HAR APP
//
//  Created by Arman Ozkaya on 01/11/2024.
//

import SwiftUI
import CoreMotion
import CoreLocation
import CoreTransferable
import SwiftCSVEncoder
import UniformTypeIdentifiers


//GAP: https://developer.apple.com/documentation/coremotion/getting_raw_accelerometer_events
// value 1.0 represents an acceleration of 9.8 meters per second (per second)

class MotionManager: NSObject, CLLocationManagerDelegate {
    let motionManager = CMMotionManager()
}


////GAP: https://swiftpackageindex.com/scottmatthewman/swiftcsvencoder/0.2.0/documentation/swiftcsvencoder/incorporatingcsv
//struct CSVFile {
//    var data: [AccelerometerData]
//    var activityName: String
//    
//    init(data: [AccelerometerData], activityName: String) {
//        self.data = data
//        self.activityName = activityName
//    }
//}
//
//extension CSVFile {
//    func csvData() -> String {
//        let table = CSVTable<AccelerometerData>(
//            columns: [
//                CSVColumn("Timestamp", \.timestamp),
//                CSVColumn("AccelX", \.accelX),
//                CSVColumn("AccelY", \.accelY),
//                CSVColumn("AccelZ", \.accelZ)
//            ]
//        )
//        return table.export(rows: data)
//    }
//}
//
//extension CSVFile: Transferable {
//    static var transferRepresentation: some TransferRepresentation {
//        DataRepresentation(exportedContentType: UTType.commaSeparatedText) { file in
//            Data(file.csvData().utf8)
//        }
//    }
//}
//
