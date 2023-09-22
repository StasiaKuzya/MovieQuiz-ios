//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Анастасия on 17.09.2023.
//

import XCTest


final class MovieQuizUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()

        continueAfterFailure = false

    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }

    func testYesButton() {
        let indexLabel = app.staticTexts["Index"]
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }

    func testNoButton() {
        let indexLabel = app.staticTexts["Index"]
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testShowAlert() {
        
        sleep(2)
           for _ in 1...10 {
               app.buttons["No"].tap()
               sleep(2)
           }

           XCTAssertTrue(app.alerts.firstMatch.exists)
           XCTAssertEqual(app.alerts.firstMatch.label, "Этот раунд окончен!")
           XCTAssertTrue(app.alerts.firstMatch.buttons["Сыграть ещё раз"].exists)
    }
    
    func testAlertDismiss() {
        sleep(1)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        app.alerts.buttons.firstMatch.tap()
        
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(app.alerts.firstMatch.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
}
