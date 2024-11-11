//
//  loginModel.swift
//  HAR APP
//
//  Created by Arman Ozkaya on 11/11/2024.
//

import Foundation

class loginModel: ObservableObject{
    @Published var authenticated: Bool
    
    init() {
        self.authenticated = false
    }
}
