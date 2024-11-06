//
//  WatchView.swift
//  WatchHARApp Watch App
//
//  Created by Arman Ozkaya on 03/11/2024.
//

import SwiftUI

struct WatchView: View {
    
    @StateObject var viewModel = ViewModel()
    //@StateObject var watchConnector = WatchToIosConnector()
    
    var body: some View {
        ScrollView{
            Text("Workout Name")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.bottom)
            Spacer()
            Text(viewModel.isRecording ? "Recording" : "Standby")
                .font(.title3)
                .scaledToFit()
                .foregroundStyle(.red)
                .padding(.bottom)
            
            Divider()
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
                Text("Heading")
                      .font(.headline)
            }
            .padding(.horizontal)
            
            Spacer()
            
            if(!viewModel.isRecording){
                Button{
                    viewModel.startCollectingSensorData()
                }label:{
                    Label("Start Workout", systemImage: "play.fill" )
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.mini)
                .backgroundStyle(.red)
                
            }else{
                Button{
                    viewModel.stopCollectingSensorData()
                }label:{
                    Label("Stop Workout", systemImage: "stop.fill" )
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.mini)
                .backgroundStyle(.red)
            }
        }
        
        .padding()
        .ignoresSafeArea()

    }
    
}

#Preview {
    WatchView()
}
