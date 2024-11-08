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
    @State var startActivity = false;
    
    var body: some View {
        VStack{
            
            ActivityIconView(activity: activity)
            
            Text("When you are ready to start your workout, tap start activity to start the sensor recordings")
                .font(.title3)
                .fontWeight(.semibold)
                .padding()
            
            
            Divider()
            ScrollView{
                VStack(alignment: .leading, spacing:8 ){
                    Text("User Acceleration")
                        .font(.headline)
                    Text(viewModel.accelerationValue ?? "No Data")
                        .font(.subheadline)
                        .padding(.bottom)
                    Text("Rotation")
                        .font(.headline)
                    Text(viewModel.gyroscopeValue ?? "No Data")
                        .font(.subheadline)
                        .padding(.bottom)
                    Text("Magnetic Vector")
                        .font(.headline)
                    Text(viewModel.magnetometerValue ?? "No Data")
                        .font(.subheadline)
                        .padding(.bottom)
            }

                
            }
            Spacer()
            if(!startActivity){
                Button {
                    viewModel.watchConnector.sendCommandToWatch(data: "Start")
                    startActivity = true;
                } label:{
                    Label("Start Activity", systemImage: "play.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .controlSize(.large)

            }else{
                Button {
                    viewModel.watchConnector.sendCommandToWatch(data: "Stop")
                    startActivity = false
                } label:{
                    Label("Stop Activity", systemImage: "stop.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .controlSize(.large)
            }
            
           
            


        }
    }
}

#Preview {
    ActivityDetailView(activity: MockData.sampleActivity, viewModel: ActivitiesViewModel())
}
