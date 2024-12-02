//
//  WatchView.swift
//  WatchHARApp Watch App
//
//  Created by Arman Ozkaya on 03/11/2024.
//

import SwiftUI

struct WatchView: View {
    @Environment(\.modelContext) var context
    
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
                HeartRateView(viewModel: viewModel)
                Text("Latitutde")
                    .font(.headline)
                Text("\(viewModel.latitude)")
                    .font(.subheadline)
                    .padding(.bottom)
                Text("Longitude")
                    .font(.headline)
                Text("\(viewModel.longitude)")
                    .font(.subheadline)
                    .padding(.bottom)
                Text("Heading")
                Text("\(viewModel.heading)")
                    .font(.subheadline)
                    .padding(.bottom)
                Text("Course")
                Text("\(viewModel.course)")
                    .font(.subheadline)
                    .padding(.bottom)
                Text("Speed")
                Text("\(viewModel.speed)")
                    .font(.subheadline)
                    .padding(.bottom)
  
                Text("Altitude")
                Text("\(viewModel.altitude)")
                    .font(.subheadline)
                    .padding(.bottom)
                    
                Text("User Acceleration")
                    .font(.headline)
                Text(viewModel.sensorData[0].accelX)
                    .font(.subheadline)
                    .padding(.bottom)
                Text(viewModel.sensorData[0].accelY)
                    .font(.subheadline)
                    .padding(.bottom)
                Text(viewModel.sensorData[0].accelZ)
                    .font(.subheadline)
                    .padding(.bottom)
                Text("Gyroscope Values")
                    .font(.headline)
                Text(viewModel.sensorData[0].gyroX)
                    .font(.subheadline)
                    .padding(.bottom)
                Text(viewModel.sensorData[0].gyroY)
                    .font(.subheadline)
                    .padding(.bottom)
                Text(viewModel.sensorData[0].gyroZ)
                    .font(.subheadline)
                    .padding(.bottom)

                Text("Magnetic Vector")
                    .font(.headline)
                Text(viewModel.sensorData[0].magX)
                    .font(.subheadline)
                    .padding(.bottom)
                Text(viewModel.sensorData[0].magY)
                    .font(.subheadline)
                    .padding(.bottom)
                Text(viewModel.sensorData[0].magZ)
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
        .onAppear {
                    viewModel.setContext(context)
                }

    }
    
}

struct HeartRateView: View {
    @ObservedObject var viewModel: ViewModel
    var body: some View {
        HStack{
            VStack {
                Image(systemName: "heart.square")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                Text("BPM")
                

            }
            Spacer()
            Text("\(viewModel.publishedHeartRate)")
                .font(.title)
                .padding(.bottom)
            Spacer()
        }


        .padding()
    }
}

#Preview {
    WatchView()
}
