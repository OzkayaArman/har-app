//
//  HAR_APPApp.swift
//  HAR APP
//
//  Created by Arman Ozkaya on 01/10/2024.
//

import SwiftUI

@main
struct HAR_APPApp: App {

    var body: some Scene {
        WindowGroup {
            MainPageView(login: loginModel())
        }
    }
}
