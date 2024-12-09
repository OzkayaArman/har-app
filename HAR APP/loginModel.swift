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
    @Published var birthdate = Date()
    @Published var errorMessage: String
    
    init() {
        self.authenticated = false
        self.firstname = ""
        self.lastname = ""
        self.errorMessage = ""
    }
    
    
    func checkUserDataFromForm() -> Bool {
        if(firstname.isEmpty){
            errorMessage = "Firstname is not entered"
            return false
        }
        
        if(birthdate.debugDescription.isEmpty){
            errorMessage = "Birthdate is not set"
            return false
        }
        
        //GAP: Code for date extraction is taken from this source https://bugfender.com/blog/swift-dates/
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date.now)
        let age = calendar.component(.year, from:birthdate)
        print(currentYear)
        print(age)
        if(currentYear - age < 18){
            errorMessage = "Users who are less than 18 years of age can not use this app"
            return false
        }
        
        self.authenticated = true
        return true
        
    }
    
    func loadUserDataFromAppleID() -> Bool{
        guard let appleUserData = UserDefaults.standard.data(forKey: "appleUser"),
        let appleUser = try? JSONDecoder().decode(AppleUser.self, from: appleUserData) else {
            errorMessage = "Authentication failed in loadUserDataFromAppleID function"
            return false
        }
        firstname = appleUser.firstName
        lastname = appleUser.lastName
        
        if(firstname.isEmpty){
            errorMessage = "Firstname is not entered"
            return false
        }
        
        self.authenticated = true;
        return true
    }
    
    func changeFirstname(newName: String){
        self.firstname = newName
    }
    
    func changeLastname(newLastName: String){
        self.lastname = newLastName
    }
    
    func changeBirthdate(newBirthDate: Date){
        self.birthdate = newBirthDate
    }
}
