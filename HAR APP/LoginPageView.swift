//
//  LoginPage.swift
//  HAR APP
//
//  Created by Arman Ozkaya on 11/11/2024.
//



import SwiftUI
import AuthenticationServices
import Foundation


//This is the first page the user sees and logs in to the app
struct LoginPageView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var login: loginModel
    @State private var promptLoginAgain = false
    @State private var datePickerWheel = false
    
    var body: some View {
    
        VStack(){
            
            Image("Login")
                .resizable()
                .scaledToFill()
                .frame(width:430, height:350)
                .ignoresSafeArea()
            
            Text("Sign In")
                .font(.title)
                .foregroundStyle(.black)
                .fontWeight(.bold)
                .scaledToFit()
                .minimumScaleFactor(0.60)
                .frame(width: 350, height: 35, alignment: .leading)
                .padding(.horizontal)
                .alert(isPresented: $promptLoginAgain) {
                        Alert(
                            title: Text("Authentication failed"),
                            message: Text("\(login.errorMessage)"),
                            dismissButton: .default(Text("Back To Login Page"))
                        )
                }
                
            Spacer()
            ScrollView{
    
                    Section(){
                        TextField("First Name *", text: $login.firstname)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.black)
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8) // Adds border
                                .stroke(Color.blue, lineWidth: 2)
                            )
                        
                        TextField("Last Name", text: $login.lastname)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.black)
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8) // Adds border
                                .stroke(Color.blue, lineWidth: 2)
                            )
                        HStack{
                            Button{
                                datePickerWheel.toggle()
                            } label: {
                                Text("Birthday *")
                                    .font(.subheadline)
                                    .foregroundStyle(.black)
                                    .padding()
                            }
                            
                            .overlay(
                                RoundedRectangle(cornerRadius: 8) // Adds border
                                .stroke(Color.blue, lineWidth: 2)
                            )
                            
                            Spacer()
                        }
             
                        
                        if(datePickerWheel){
                            DatePicker("Birthday *", selection: $login.birthdate,
                                       displayedComponents: [.date])
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .frame(width:100, height:100)
                            .padding(10)
                        }

                    }
                    
                    .padding(15)
                
                    Button{
                        promptLoginAgain = !login.checkUserDataFromForm()
                    } label: {
                        Label("Login", systemImage: "person.fill.checkmark")
                            .frame(width: 350, height: 5 , alignment: .center)
                            .padding(.vertical)
                            
                    }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .cornerRadius(10)
                    
                    Text("OR")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                    
                    SignInWithAppleButton(
                        .signIn,
                        onRequest: configure,
                        onCompletion: handle
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .padding()
                }
        }
                
    }
    
    /*
    //https://www.youtube.com/watch?v=O2FVDzoAB34&t=654s
     GAP: The following code and loginfunction inn login model that enables login through apple id was developed by following the tutorial above
    */
    func configure(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }

    func handle(_ authResult: Result<ASAuthorization, Error>) {
        switch authResult {
        case .success(let auth):
            print(auth)
            switch auth.credential {
            case let appleIdCredentials as ASAuthorizationAppleIDCredential:
                //For first time sign ups, obtain details from apple user structure and save details to UserDefaults
                if let appleUser = AppleUser(credentials: appleIdCredentials),
                   let appleUserData = try? JSONEncoder().encode(appleUser) {
                    UserDefaults.standard.setValue(appleUserData, forKey: "appleUser")
                    print("Saved apple user", appleUser)
                    promptLoginAgain = !login.loadUserDataFromAppleID()
                } else {
                    //For returning users obtain details from UserDefaults
                    print("Returning user",
                          appleIdCredentials.fullName ?? "No full name",
                          appleIdCredentials.user)
                    guard let appleUserData = UserDefaults.standard.data(forKey: "appleUser"),
                        let appleUser = try? JSONDecoder().decode(AppleUser.self, from: appleUserData) else { return }
                    print(appleUser)
                    promptLoginAgain = !login.loadUserDataFromAppleID()
                }
            default:
                print(auth.credential)
            }
        case .failure(let error):
            print(error)
        }
    }
}


struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPageView(login: loginModel())
            .preferredColorScheme(.dark)
    }
    
}



