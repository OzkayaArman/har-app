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
    @ObservedObject var loginModel: loginModel
    @ObservedObject var preferencesModel: Preferences
    
    @State private var shouldTabHide = false
    @State private var startActivity = false
    @State private var showingExporter = false
    @State private var showConfirmation = false
    @State private var showAlertConnectivity = false
    @State private var csvFile: CSVFile?
   
    
    let timer = Timer.publish(every: 1,tolerance: 0.5, on: .main, in: .common).autoconnect()

    
    var body: some View {
        VStack{
            
            ActivityIconView(activity: activity)
            
            Text("When you are ready to start your workout, tap start activity to start the sensor recordings.")
                .font(.title3)
                .fontWeight(.semibold)
                .padding()
                .alert(isPresented: $showConfirmation) {
                        Alert(
                            title: Text("Success"),
                            message: Text("CSV file saved successfully!"),
                            dismissButton: .default(Text("OK"))
                        )
                }
            
            Divider()
            Text("Remainining Time In Activity Collection Session")
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding()
            
            Text("\(Int(preferencesModel.sessionDurationView)) s")
                .font(.system(size: 70))
                .fontWeight(.light)
                .foregroundColor(.red)
                .frame(width:250, height:150)
                .onReceive(timer) { time in
                    if (preferencesModel.sessionDurationView == 0){
                        timer.upstream.connect().cancel()
                        //Call clean sensor data function
                        viewModel.watchConnector.sendCommandToWatch(data: "Stop")
                    } else if (preferencesModel.sessionDurationView  > 0 && startActivity == true){
                        preferencesModel.sessionDurationView  -= 1
                    }
                    
                }
                
                
            Spacer()
            if(!startActivity){
                //Start Activity Button
    
                ButtonView(labelString: "Start Activity", systemImageString: "play.fill", commandToSend: "Start",
                           startActivity: $startActivity, shouldTabHide: $shouldTabHide, countdown: $preferencesModel.sessionDurationView, showAlertConnectivity: $showAlertConnectivity, viewModel: viewModel, preferencesModel: preferencesModel)
                .alert(isPresented: $showAlertConnectivity) {
                            Alert(
                                title: Text("Oops"),
                                message: Text("Please connect your Apple Watch and open the Watch app"),
                                dismissButton: .default(Text("OK"))
                            )
                        }
            }else{
                //Stop Activity Button
                
                ButtonView(labelString: "Stop Activity", systemImageString: "stop.fill", commandToSend: "Stop",
                           startActivity: $startActivity, shouldTabHide: $shouldTabHide, countdown: $preferencesModel.sessionDurationView ,showAlertConnectivity: $showAlertConnectivity, viewModel: viewModel, preferencesModel: preferencesModel)
            }
            
            if (viewModel.exportReady){
                ExportView(viewModel: viewModel, loginModel: loginModel, activity: activity, csvFile: $csvFile, showingExporter: $showingExporter, showConfirmation: $showConfirmation,shouldTabHide: $shouldTabHide)
            }
        
        }
        .navigationBarBackButtonHidden(shouldTabHide)
        .toolbar(shouldTabHide ? .hidden : .visible, for: .tabBar)
    }//End of activity Detail View
}


struct ButtonView: View {
    var labelString: String
    var systemImageString: String
    var commandToSend : String
    @Binding var startActivity: Bool
    @Binding var shouldTabHide: Bool
    @Binding var countdown: Double
    @Binding var showAlertConnectivity:Bool
    
    @ObservedObject var viewModel: ActivitiesViewModel
    @ObservedObject var preferencesModel: Preferences
    
    var body: some View {
        Button {
            let response = viewModel.watchConnector.sendCommandToWatch(data: commandToSend)
            if(!response){
                showAlertConnectivity = true
            }
        } label:{
            Label(labelString, systemImage: systemImageString)
        }
        .buttonStyle(.borderedProminent)
        .tint(labelString == "Start Activity" ? .green : .red)
        .controlSize(.large)
        .padding(.bottom)
        .onChange(of: viewModel.receivedConfirmation){
            if(viewModel.receivedConfirmation){
                //Handle specific events depending on start and stop command
                if(commandToSend == "Start"){
                    shouldTabHide = true
                    startActivity = true
                    viewModel.receivedConfirmation.toggle()
                }else{
                    startActivity = false
                    countdown = preferencesModel.sessionDuration
                    //Call clean sensor data function
                    viewModel.cleanSensorData()
                    viewModel.receivedConfirmation.toggle()
                }
            }
        }
    }
}



struct ActivityIconView: View {
    let activity: Activities
    
    var body: some View {
        VStack {
            Image(systemName: activity.imageName)
                .resizable()
                .frame(width: 130, height: 130)
            Text(activity.name)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.brown)
            }
            .padding()
            
    }
}


struct ExportView: View {
    @ObservedObject var viewModel: ActivitiesViewModel
    @ObservedObject var loginModel: loginModel
    let activity: Activities
    @Binding var csvFile: CSVFile?
    @Binding var showingExporter: Bool
    @Binding var showConfirmation: Bool
    @Binding var shouldTabHide: Bool
    
    var body: some View {
        Button(){
            csvFile = CSVFile(data: viewModel.sensorData, activityName: activity.name, userName: loginModel.firstname)
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
            defaultFilename: (loginModel.firstname) + " " + activity.name + " " + "\(Int(Date().timeIntervalSince1970))"
        ) { result in
            switch result {
            case .success(let url):
                print("CSV file saved successfully at: \(url)")
                shouldTabHide = false
                viewModel.exportReady = false
                showingExporter = false
                showConfirmation = true;
            case .failure(let error):
                print("Error saving CSV file: \(error.localizedDescription)")
                shouldTabHide = false
                viewModel.exportReady = false
                showingExporter = false
            }
        }
    }
}


#Preview {
    
    ActivityDetailView(activity: ActivityMetaData().sampleActivity, viewModel: ActivitiesViewModel(preferencesModel: Preferences()),loginModel: loginModel(), preferencesModel: Preferences())
}
