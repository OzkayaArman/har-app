//
//  NewActivityAdditionTests.swift
//  HAR_APP_Unit_Tests
//
//  Created by Arman Ozkaya on 08/12/2024.
//

import XCTest
import SwiftUI
@testable import HAR_APP
final class NewActivityAdditionTests: XCTestCase {
    
    func testSheetValidSave(){
        //Arrange
        let login =  loginModel()
        let activityList = ActivityMetaData()
        let prefs = Preferences()
        let viewModel = ActivitiesViewModel(preferencesModel: prefs)
        let activityGridView = ActivityGridView(viewModel: viewModel, login: login, activityList: activityList, preferencesModel: prefs)
        @State var addingNewActivity = false
        //Act
        @State var newActivityName = "Rugby"
        
        let sheet = NewActivitySheet(
            addingNewActivity: $addingNewActivity,
            newActivityName: $newActivityName,
            activityMetaData: activityList
        )
        //Assert
        XCTAssertTrue(sheet.checkActivityNameIsNotEmpty())
    }
    
    func testSheetInvalidSave(){
        //Arrange
        let login =  loginModel()
        let activityList = ActivityMetaData()
        let prefs = Preferences()
        let viewModel = ActivitiesViewModel(preferencesModel: prefs)
        let activityGridView = ActivityGridView(viewModel: viewModel, login: login, activityList: activityList, preferencesModel: prefs)
        @State var addingNewActivity = false
        
        //Act
        @State var newActivityName = ""
        
        let sheet = NewActivitySheet(
            addingNewActivity: $addingNewActivity,
            newActivityName: $newActivityName,
            activityMetaData: activityList
        )
        
        //Assert
        XCTAssertFalse(sheet.checkActivityNameIsNotEmpty())

    }
    
    func testActivityAddition(){
        //Arrange
        let login =  loginModel()
        let activityList = ActivityMetaData()
        let prefs = Preferences()
        let viewModel = ActivitiesViewModel(preferencesModel: prefs)
        let activityGridView = ActivityGridView(viewModel: viewModel, login: login, activityList: activityList, preferencesModel: prefs, newActivityName:"Rugby")
        activityGridView.didDismiss()
        
        // Assert
        XCTAssertTrue(activityList.activityArray.contains(where: { $0.name == "Rugby" }))
    }
}
    




