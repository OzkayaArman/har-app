//
//  LoginPage.swift
//  HAR APP
//
//  Created by Arman Ozkaya on 11/11/2024.
//

import SwiftUI
import AuthenticationServices
import Foundation


struct LoginPageView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var login: loginModel
    
    var body: some View {
            VStack{
                SignInWithAppleButton(
                    .signIn,
                    onRequest: configure,
                    onCompletion: handle
                )
                .signInWithAppleButtonStyle(
                    colorScheme == .dark ? .white : .black
                )
                .frame(height: 50)
                .padding()
            }
        
    }

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
                    print("saved apple user", appleUser)
                    login.authenticated = true
                } else {
                    //For returning users obtain details from UserDefaults
                    print("missing some fields or returning user",
                          appleIdCredentials.fullName ?? "No full name",
                          appleIdCredentials.user)
                    guard let appleUserData = UserDefaults.standard.data(forKey: "appleUser"),
                        let appleUser = try? JSONDecoder().decode(AppleUser.self, from: appleUserData) else { return }
                    print(appleUser)
                    login.authenticated = true
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
    }
}
