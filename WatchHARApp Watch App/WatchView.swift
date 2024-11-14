//
//  WatchView.swift
//  WatchHARApp Watch App
//
//  Created by Arman Ozkaya on 03/11/2024.
//

import SwiftUI

struct WatchView: View {
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        ScrollView{
            Text(viewModel.isExtended ? "Extended" : "Not Extended")
                .font(.title3)
                .scaledToFit()
                .foregroundStyle(.red)
                .padding(.bottom)
            Spacer()
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
                Text(viewModel.accelerationValue ?? "No Data")
                    .font(.subheadline)
                    .padding(.bottom)
                Text("Gyroscope Values")
                    .font(.headline)
                Text(viewModel.gyroscopeValue ?? "No Data")
                    .font(.subheadline)
                    .padding(.bottom)
                Text("Magnetometer Values")
                    .font(.headline)
                Text(viewModel.magnetometerValue ?? "No Data")
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
