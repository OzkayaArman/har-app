//
//  AuthenticationTests.swift
//  HAR_APP_Unit_Tests
//
//  Created by Arman Ozkaya on 08/12/2024.
//

//
//  HAR_APP_Unit_Tests.swift
//  HAR_APP_Unit_Tests
//
//  Created by Arman Ozkaya on 08/12/2024.
//

import XCTest
@testable import HAR_APP
final class AuthenticationTests: XCTestCase {
    
    func testSuccessfulLogin(){
        //Arrange
        let login = loginModel()
        login.firstname = "Jack"
        login.lastname = "Sparrow"
        let dateComponents = DateComponents(year: 2001, month: 8, day: 8)
        guard let date = Calendar.current.date(from: dateComponents) else {return}
        login.birthdate = date
        
        //Act
        let result: Bool = login.checkUserDataFromForm()
        
        //Assert
        XCTAssertTrue(result)
    }
    
    func testMissingFirstName(){
        //Arrange
        let login = loginModel()
        login.lastname = "Sparrow"
        let dateComponents = DateComponents(year: 2001, month: 8, day: 8)
        guard let date = Calendar.current.date(from: dateComponents) else {return}
        login.birthdate = date
        
        //Act
        let result: Bool = login.checkUserDataFromForm()
        
        //Assert
        XCTAssertFalse(result)
    }
    
    func testMissingBirthdate(){
        //Arrange
        let login = loginModel()
        login.firstname = "Jack"
        login.lastname = "Sparrow"
        
        //Act
        let result: Bool = login.checkUserDataFromForm()
        
        //Assert
        XCTAssertFalse(result)
    }
    
    func testUserYoungerThan18(){
        //Arrange
        let login = loginModel()
        login.firstname = "Jack"
        login.lastname = "Sparrow"
        
        let calendar = Calendar.current
        let now = Date()
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
        dateComponents.year = (dateComponents.year ?? 0) - 17
        
        
        login.birthdate = calendar.date(from: dateComponents) ?? Date()
        print(login.birthdate)
        //Act
        let result: Bool = login.checkUserDataFromForm()
        
        //Assert
        XCTAssertFalse(result)
    }
    
    func testUserRightAge(){
        //Arrange
        let login = loginModel()
        login.firstname = "Jack"
        login.lastname = "Sparrow"
        
        let calendar = Calendar.current
        let now = Date()
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
        dateComponents.year = (dateComponents.year ?? 0) - 18
        
        
        login.birthdate = calendar.date(from: dateComponents) ?? Date()
        print(login.birthdate)
        //Act
        let result: Bool = login.checkUserDataFromForm()
        
        //Assert
        XCTAssertTrue(result)
    }
    
    
    func testChangingFirstname(){
        //Arrange
        let login = loginModel()
        login.firstname = "Jack"
        login.lastname = "Sparrow"
        let dateComponents = DateComponents(year: 2001, month: 8, day: 8)
        guard let date = Calendar.current.date(from: dateComponents) else {return}
        login.birthdate = date
        login.changeFirstname(newName: "John")
    
        //Assert
        XCTAssertEqual(login.firstname, "John")
    }
    
    func testChangingLastname(){
        //Arrange
        let login = loginModel()
        login.firstname = "Jack"
        login.lastname = "Sparrow"
        let dateComponents = DateComponents(year: 2001, month: 8, day: 8)
        guard let date = Calendar.current.date(from: dateComponents) else {return}
        login.birthdate = date
        login.changeLastname(newLastName: "Smith")
    
        //Assert
        XCTAssertEqual(login.lastname, "Smith")
    }
    
    func testChangingBirthdate(){
        //Arrange
        let login = loginModel()
        login.firstname = "Jack"
        login.lastname = "Sparrow"
        let dateComponents = DateComponents(year: 2001, month: 8, day: 8)
        guard let date = Calendar.current.date(from: dateComponents) else {return}
        login.birthdate = date
        
        let dateComponents2 = DateComponents(year: 2005, month: 8, day: 8)
        guard let date2 = Calendar.current.date(from: dateComponents2) else {return}
        login.birthdate = date2
        login.changeBirthdate(newBirthDate: date2)
    
        //Assert
        XCTAssertEqual(login.birthdate, date2)
    }

}


