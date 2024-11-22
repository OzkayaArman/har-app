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
    //Observed object expects viewModel from parent view which is MainPageView
    @ObservedObject var viewModel: ActivitiesViewModel
    
    @State private var startActivity = false
    @State private var showingExporter = false
    @State private var csvFile: CSVFile?
    @State private var showAlert = false
    @State private var showAlertConnectivity = false
    @State private var successfulDataCollection = false
    
    var body: some View {
        VStack{
            
            ActivityIconView(activity: activity)
            
            Text("When you are ready to start your workout, tap start activity to start the sensor recordings")
                .font(.title3)
                .fontWeight(.semibold)
                .padding()
                .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Success"),
                            message: Text("CSV file saved successfully!"),
                            dismissButton: .default(Text("OK"))
                        )
                }

            
            
            Divider()
            Spacer()
            if(!startActivity){
                //Start Activity Button
                Button {
                    let status = viewModel.watchConnector.sendCommandToWatch(data: "Start")
                    if(status){
                        startActivity = true;
                    }else{
                        showAlertConnectivity = true
                    }
                    
                } label:{
                    Label("Start Activity", systemImage: "play.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .controlSize(.large)
                .alert(isPresented: $showAlertConnectivity) {
                            Alert(
                                title: Text("Oops"),
                                message: Text("Please connect your Apple Watch and open the Watch app"),
                                dismissButton: .default(Text("OK"))
                            )
                        }
            }else{
                //Stop Activity Button
                Button {
                    let status = viewModel.watchConnector.sendCommandToWatch(data: "Stop")
                    if(status){
                        startActivity = false
                        successfulDataCollection = true
                        //Call clean sensor data function
                        viewModel.cleanSensorData()
                    }
                } label:{
                    Label("Stop Activity", systemImage: "stop.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .controlSize(.large)
                .padding(.bottom)
                
            }
            
            if(viewModel.exportReady){
                Button(){
                    csvFile = CSVFile(data: viewModel.sensorData, activityName: activity.name, userName: viewModel.firstName ?? "noUser" )
                    showingExporter = true
                } label:{
                    Label("Export", systemImage: "square.and.arrow.up.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .controlSize(.large)
                .fileExporter(
                    isPresented: $showingExporter,
                    document: csvFile,
                    contentType: .commaSeparatedText,
                    defaultFilename: (viewModel.firstName ?? "noUser") + " " + activity.name
                ) { result in
                    switch result {
                    case .success(let url):
                        print("CSV file saved successfully at: \(url)")
                        viewModel.exportReady = false
                        showingExporter = false
                        showAlert = true;
                    case .failure(let error):
                        print("Error saving CSV file: \(error.localizedDescription)")
                        viewModel.exportReady = false
                        showingExporter = false
                    }
                }
            }
        
        }
    }
}

#Preview {
    ActivityDetailView(activity: MockData.sampleActivity, viewModel: ActivitiesViewModel())
}
