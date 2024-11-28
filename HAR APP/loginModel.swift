//
//  loginModel.swift
//  HAR APP
//
//  Created by Arman Ozkaya on 11/11/2024.
//

import Foundation

class loginModel: ObservableObject{
    @Published var authenticated: Bool
    @Published var firstname: String
    @Published var lastname: String
    @Published var email: String
    @Published var birthdate = Date()
    
    init() {
        self.authenticated = false
        self.firstname = ""
        self.lastname = ""
        self.email = ""
        self.birthdate = Date.now
    }
    
    func loadUserData() {
        if(firstname == ""){
            guard let appleUserData = UserDefaults.standard.data(forKey: "appleUser"),
                let appleUser = try? JSONDecoder().decode(AppleUser.self, from: appleUserData) else { return }
            firstname = appleUser.firstName
            lastname = appleUser.lastName
            email = appleUser.email
        }
    }
}
