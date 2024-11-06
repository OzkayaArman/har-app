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
    
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible())]
    
    var isShowingDetailView = false
    
    var watchConnector = WatchConnector()
}
