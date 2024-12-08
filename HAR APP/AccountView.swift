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
    
    @State  private var accelerometer = true;
    @State private var gyroscope = true;
    @State private var magnetometer = true;
    @State private var gps = true;
    @State private var heartRateSensor = true;
    @State private var music = false;
    
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
                    Toggle("Accelerometer", isOn: $accelerometer)
                    Toggle("Magnetometer", isOn: $magnetometer)
                    Toggle("Gyroscope", isOn: $gyroscope)
                    Toggle("Location Services: GPS", isOn: $gps)
                    Toggle("Heart Rate Sensor", isOn: $heartRateSensor)
                    Toggle("Music Listening Monitoring", isOn: $music)
                    
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
    AccountView(loginModel: loginModel())
}
