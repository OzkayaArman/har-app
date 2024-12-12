//
//  AccountView.swift
//  HAR APP
//
//  Created by Arman Ozkaya on 08/11/2024.
//

import SwiftUI

struct AccountView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var birthdate = Date()
    @ObservedObject var preferencesModel: Preferences
    
    @ObservedObject var loginModel: loginModel
    
    var body: some View {
        NavigationStack {
            Form{
                Section(header: Text("Personal Info")){
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    DatePicker("Birthday", selection: $birthdate,
                               displayedComponents: .date)
                    
                    Button{
                        loginModel.changeFirstname(newName: self.firstName)
                        loginModel.changeLastname(newLastName: self.lastName)
                        loginModel.changeBirthdate(newBirthDate: self.birthdate)
                    } label: {
                        Text("Save Changes")
                    }
                    
                }
                Section(header: Text("Preferences")){
                    Toggle("Accelerometer", isOn: $preferencesModel.accelerometer)
                    Toggle("Magnetometer", isOn: $preferencesModel.magnetometer)
                    Toggle("Gyroscope", isOn: $preferencesModel.gyroscope)
                    Toggle("Location Services: GPS", isOn: $preferencesModel.gps)
                    Toggle("Heart Rate Sensor", isOn: $preferencesModel.heartRateSensor)
                    VStack{
                        Slider(value: $preferencesModel.sessionDuration, in: 10...600,step:5)
                        Text("Session Duration in Seconds: \(Int (preferencesModel.sessionDuration))")
                    }
                    
                    
                }
            }
                .navigationTitle("My Account 👤")
                .onAppear(perform: loadUserData)
        }
    }
    
    func loadUserData() {
        firstName = loginModel.firstname
        lastName = loginModel.lastname
        birthdate = loginModel.birthdate
    }

}



#Preview {
    AccountView(preferencesModel: Preferences(), loginModel: loginModel())
}
