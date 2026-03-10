
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
    
    func testYesButton() throws {
        
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        
    }
    
    func testNoButton() throws {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        
        
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        
    }
    
    
        func testIndex() throws {
        
        sleep(5)
        
        let indexLabel = app.staticTexts["Index"]
        print("Текст ДО тапа: \(indexLabel.label)")
        XCTAssertEqual(indexLabel.label, "1/10")
        
        app.buttons["No"].tap()
        
        sleep(2)
        
        
        print("Текст ПОСЛЕ тапа: \(indexLabel.label)")
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    func testAlertForButtonYes() throws {
        
        sleep(3)
        
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            
            sleep(2)
        }
        
        sleep(3)
        
        let alert = app.alerts["Этот раунд окончен!"]
        
        sleep(5)
        
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз")
    }
    
    func testAlertDismiss() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Этот раунд окончен!"]
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
    
    
    
}
