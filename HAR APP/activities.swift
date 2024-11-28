
import Foundation
import SwiftUI

struct Activities: Hashable, Identifiable{
    let id = UUID()
    let name: String
    let imageName: String

}

class ActivityMetaData: ObservableObject {
    //Sample activity is defined for preview / debug purposes only
    var sampleActivity = Activities(name: "Indoor Running", imageName: "figure.run.treadmill.circle.fill")
    
    @Published var activityArray: [Activities] = [
        Activities(name: "Indoor Running",
                  imageName: "figure.run.treadmill.circle.fill"),
        
        Activities(name: "Outdoor Running",
                  imageName: "figure.run.circle.fill"),
        
        
        Activities(name: "Jumping Ropes",
                  imageName: "figure.jumprope.circle.fill"),
        
        Activities(name: "Basketball",
                  imageName: "figure.basketball.circle.fill"),


        Activities(name: "Indoor Cycling",
                  imageName: "figure.indoor.cycle.circle.fill"),
        
        Activities(name: "Rowing",
                  imageName: "figure.indoor.rowing.circle.fill"),
        
        Activities(name: "Walking",
                  imageName: "figure.walk.circle.fill"),
        
        Activities(name: "Outdoor Cycling",
                  imageName: "figure.outdoor.cycle.circle.fill"),
        
        Activities(name: "Stair Stepper",
                  imageName: "figure.stair.stepper.circle.fill")
        
    ]
}






