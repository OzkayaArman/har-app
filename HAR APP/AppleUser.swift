//
//  AppleUser.swift
//  HAR APP
//
//  Created by Arman Ozkaya on 11/11/2024.
//

import Foundation
import AuthenticationServices
import SwiftUI

/*
//https://www.youtube.com/watch?v=O2FVDzoAB34&t=654s
 GAP: The code in this page was developed by following the tutorial above
*/

//This struct conforms to codable so that the struct can be encoded to JSON while being saved to UserDefault
class AppleUser: Codable, ObservableObject {
    var userId: String
    var firstName: String
    var lastName: String
    
    //Failizable init because the only time fullname and email is received from apple auth framework is FIRST sign up only
    //For returning users, nil will be returned and user details will be obtained from default users rather than this structure
    init?(credentials: ASAuthorizationAppleIDCredential) {
        guard
            let firstName = credentials.fullName?.givenName,
            let lastName = credentials.fullName?.familyName
        else { return nil }
        
        self.userId = credentials.user
        self.firstName = firstName
        self.lastName = lastName
    }
    
   
    init(userId: String, firstName: String, lastName: String, birthdate: Int) {
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
    }
    
    // Default initializer for previews and testing
       init() {
           self.userId = "12345"
           self.firstName = "Malory"
           self.lastName = "Testing"
       }
}

