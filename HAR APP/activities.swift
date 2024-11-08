
import Foundation
import SwiftUI

struct Activities: Hashable, Identifiable{
    let id = UUID()
    let name: String
    let imageName: String

}

struct MockData {
    
    static let sampleActivity = Activities(name: "Indoor Running",
                                           imageName: "figure.run.treadmill.circle.fill")
    static let activityArray = [
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


struct ActivityIconView: View {
    let activity: Activities
    
    var body: some View {
        VStack {
            Image(systemName: activity.imageName)
                .resizable()
                .frame(width: 90, height: 90)
            Text(activity.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color(.label))
                .scaledToFit()
                .minimumScaleFactor(0.5)
            }
            .padding()
            
    }
}




