//
//  WatchView.swift
//  WatchHARApp Watch App
//
//  Created by Arman Ozkaya on 03/11/2024.
//

import SwiftUI

struct WatchView: View {
    
    //WatchView initializes the ViewModel
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        ScrollView{
            
            Text(viewModel.isRecording ? "Recording" : "Standby")
                .font(.title3)
                .scaledToFit()
                .foregroundStyle(.red)
                .padding(.bottom)
            
            Divider()
            
            VStack(alignment: .leading, spacing:8 ){
                HeartRateView()
                Text("Accelerometer")
                    .font(.headline)
            
                Text("User Acceleration")
                    .font(.headline)
                Text(viewModel.accelerationValueX ?? "No Data")
                    .font(.subheadline)
                    .padding(.bottom)
                Text(viewModel.accelerationValueY ?? "No Data")
                    .font(.subheadline)
                    .padding(.bottom)
                Text(viewModel.accelerationValueZ ?? "No Data")
                    .font(.subheadline)
                    .padding(.bottom)
                Text("Gyroscope Values")
                    .font(.headline)
                Text(viewModel.gyroscopeValueX ?? "No Data")
                    .font(.subheadline)
                    .padding(.bottom)
                Text(viewModel.gyroscopeValueY ?? "No Data")
                    .font(.subheadline)
                    .padding(.bottom)
                Text(viewModel.gyroscopeValueZ ?? "No Data")
                    .font(.subheadline)
                    .padding(.bottom)

                Text("Magnetic Vector")
                    .font(.headline)
                Text(viewModel.magnetometerValueX ?? "No Data")
                    .font(.subheadline)
                    .padding(.bottom)
                Text(viewModel.magnetometerValueY ?? "No Data")
                    .font(.subheadline)
                    .padding(.bottom)
                Text(viewModel.magnetometerValueZ ?? "No Data")
                    .font(.subheadline)
                    .padding(.bottom)
                
            }
            .padding()
            
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
                    print("The send button is activated")
                }label:{
                    Label("Stop Workout", systemImage: "stop.fill" )
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.mini)
                .backgroundStyle(.red)
            }
        }
        
        .padding()
        .ignoresSafeArea(.container, edges: .bottom)

    }
    
    struct HeartRateView: View {

        var body: some View {
            VStack {
                Image(systemName: "heart.square")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                Text("BPM")

            }
            .padding()
        }
    }
    
    
}

#Preview {
    WatchView()
}
