//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Kirill on 27.09.2024.
//

import XCTest

class Image_FeedUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    func testAuth() throws {
        
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["LogIn"].tap()
        
        let webView = app.webViews["WebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 6))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 6))
        
        loginTextField.tap()
        webView.swipeUp()
        loginTextField.typeText("тут вводим логин почтой")
        if app.keyboards.element(boundBy: 0).exists {
            app.toolbars.buttons["Done"].tap()
        }
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 3))
        
        passwordTextField.tap()
        webView.swipeUp()
        passwordTextField.typeText("тут вводим длинный пароль")
        if app.keyboards.element(boundBy: 0).exists {
            app.toolbars.buttons["Done"].tap()
        }
        
        webView.buttons["Login"].tap()
        
        let cell = app.tables.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        
        let app = XCUIApplication()
        app.launch()
        
        let table = app.tables.firstMatch
        
        table.swipeUp()
        sleep(2)
        
        let topCell = table.cells.element(boundBy: 0)
        XCTAssertTrue(topCell.waitForExistence(timeout: 3))
        
        let likeButton = topCell.buttons["LikeButton"].firstMatch
        XCTAssertTrue(likeButton.waitForExistence(timeout: 3))
        
        likeButton.tap()
        sleep(2)
        likeButton.tap()
        sleep(2)
        
        topCell.tap()
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        
        image.pinch(withScale: 2, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let backButton = app.buttons["BackButton"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 3))
        
        backButton.tap()
        XCTAssertTrue(topCell.waitForExistence(timeout: 3))
    }
    
    func testProfile() throws {
        
        let app = XCUIApplication()
        app.launch()
        
        sleep(4)
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(1)
        
        XCTAssertTrue(app.staticTexts["тут вводим Имя Фамилия"].exists)
        XCTAssertTrue(app.staticTexts["тут вводим @никнейм"].exists)
        
        app.buttons["LogoutButton"].tap()
        sleep(1)
        
        let alert = app.alerts["Logout"]
        XCTAssertTrue(alert.waitForExistence(timeout: 1))
        
        alert.scrollViews.otherElements.buttons["Да"].tap()
        sleep(1)
        XCTAssertTrue(app.buttons["LogIn"].waitForExistence(timeout: 2))
    }
}
