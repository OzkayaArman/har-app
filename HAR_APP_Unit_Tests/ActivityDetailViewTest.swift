//
//  ActivityDetailViewTest.swift
//  HAR_APP_Unit_Tests
//
//  Created by Arman Ozkaya on 11/12/2024.
//

import XCTest
@testable import HAR_APP
final class ActivityDetailViewTest: XCTestCase {
    
    func testStartingActivitySuccessfuly(){
        //Arrange
        let login =  loginModel()
        let activityList = ActivityMetaData()
        let viewModel = ActivitiesViewModel()
        let page = ActivityDetailView(activity: activityList.sampleActivity, viewModel: viewModel, loginModel: login)
        //Act
        
        //Assert
    }
    
    func testStartingActivityUnSucceessfuly(){
        
    }
    
    func testSavingActivitySuccessfuly(){
        
    }
    
    func testSavingActivityUnSuccessfuly(){
    }

}
