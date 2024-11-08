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


final class ActivitiesViewModel: ObservableObject {
    @Published var accelerationValue: String?
    @Published var gyroscopeValue: String?
    @Published var magnetometerValue: String?
    
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible())]
    
    var watchConnector: WatchConnector
    
    init() {
        self.watchConnector = WatchConnector()
        self.watchConnector.activityViewModel = self // Pass activityViewModel reference
    }

    
    var isShowingDetailView = false
    
}

///GAP: https://swiftpackageindex.com/scottmatthewman/swiftcsvencoder/0.2.0/documentation/swiftcsvencoder/incorporatingcsv
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

