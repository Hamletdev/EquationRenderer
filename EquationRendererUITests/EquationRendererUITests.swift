//
//  EquationRendererUITests.swift
//  EquationRendererUITests
//
//  Created by Amit Chaudhary on 11/23/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import XCTest
@testable import EquationRenderer


class EquationRendererUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testUIComponents() throws {
        
        let eqTextField = app.textFields["Enter Equation"]
        
        // app.tables/*@START_MENU_TOKEN@*/.staticTexts["\\lim_{h \\to 0} \\frac{f(a+h)-f(a)}{h}"]/*[[".cells.staticTexts[\"\\\\lim_{h \\\\to 0} \\\\frac{f(a+h)-f(a)}{h}\"]",".staticTexts[\"\\\\lim_{h \\\\to 0} \\\\frac{f(a+h)-f(a)}{h}\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).tap()
        let shareButton =  app/*@START_MENU_TOKEN@*/.staticTexts["Share"]/*[[".buttons[\"Share\"].staticTexts[\"Share\"]",".staticTexts[\"Share\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        // app/*@START_MENU_TOKEN@*/.navigationBars["UIActivityContentView"]/*[[".otherElements[\"ActivityListView\"].navigationBars[\"UIActivityContentView\"]",".navigationBars[\"UIActivityContentView\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.buttons["Close"].tap()
        let imageLabel = app.staticTexts["IMAGE LOADED FROM CACHE"]
        let logoLabel = app.staticTexts["robart  Formula Renderer"]
        
        
        XCTAssertTrue(eqTextField.exists)
        XCTAssertTrue(shareButton.exists)
        XCTAssertFalse(imageLabel.exists)
        XCTAssertTrue(logoLabel.exists)
        
        
    }
    
}
