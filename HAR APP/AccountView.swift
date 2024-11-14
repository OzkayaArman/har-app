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
    @State private var email = ""
    @State private var birthdate = Date()
    @State  private var accelerometer = true;
    @State private var gyroscope = true;
    @State private var magnetometer = true;
    @State private var gps = false;
    @State private var heartRateSensor = false;
    @State private var music = false;
    
    @ObservedObject var viewModel: ActivitiesViewModel
    
    var body: some View {
        NavigationStack {
            Form{
                Section(header: Text("Personal Info")){
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    DatePicker("Birthday", selection: $birthdate,
                               displayedComponents: .date)
                    
                    Button{
                        
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
        firstName = viewModel.firstName ?? ""
        lastName = viewModel.lastName ?? ""
        email = viewModel.email ?? ""

    }

}



#Preview {
    AccountView(viewModel: ActivitiesViewModel())
}
