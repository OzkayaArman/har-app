//
//  ActivityDetailView.swift
//  HAR APP
//
//  Created by Arman Ozkaya on 02/11/2024.
//

import SwiftUI

struct ActivityDetailView: View {
    //Struct name is Activities
    var activity: Activities
    @ObservedObject var viewModel: ActivitiesViewModel
    @ObservedObject var connector: WatchConnector
    
    var body: some View {
        VStack{
            
            ActivityIconView(activity: activity)
            
            Text("When you are ready to start your workout, tap start activity to start the sensor recordings")
                .font(.title3)
                .fontWeight(.semibold)
                .padding()
            Spacer()
            
            Button {
                //connector.sendStartActivity()
            } label:{
                Label("Start Activity", systemImage: "play.fill")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

        }
    }
}

#Preview {
    ActivityDetailView(activity: MockData.sampleActivity, viewModel: ActivitiesViewModel(), connector: WatchConnector() )
}
