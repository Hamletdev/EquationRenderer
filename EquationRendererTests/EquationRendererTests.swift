//
//  EquationRendererTests.swift
//  EquationRendererTests
//
//  Created by Amit Chaudhary on 11/22/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//


import XCTest
@testable import EquationRenderer

class EquationRendererTests: XCTestCase {
    
    //system under test (EquationViewController)
    var sut: EquationViewController!
    
    var sut1: URLSession!
    
    var wikiHash: String?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = EquationViewController()
        sut.loadViewIfNeeded()
        sut1 = URLSession(configuration: .default)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        sut1 = nil
    }
    
    
    //MARK: - TEST FOR ADDSHAREBUTTON (UIBUTTON)
    
    //should pass
    func testControlEventForShareButton() throws {
        let shareButton = sut.addShareButton
        let controlEvents = shareButton.allControlEvents
        XCTAssertTrue(controlEvents.contains(.touchUpInside))
    }
    
    
    //should fail
    func testStateOfShareButton() throws {
        let shareButton: UIButton = sut.addShareButton
        XCTAssertTrue(shareButton.isEnabled)
    }
    
    
    func testIfShareButtonHasActionAssigned() throws {
        
        //Check if Controller has UIButton property
        let shareButton: UIButton = sut.addShareButton
        
        //should pass
        XCTAssertNotNil(shareButton, "Equation View Controller does have a UIButton property")
        
        //should pass as button is assigned to @objc method.
        XCTAssert(sut.responds(to: #selector(sut.shareRenderedImage)))
        
        // test should fail as button is not enabled on viewDidLoad()
        guard let shareButtonActions = shareButton.actions(forTarget: sut, forControlEvent: .touchUpInside) else {
            XCTFail("UIButton does not have actions assigned for Control Event .touchUpInside")
            return
        }
        
        // Assert UIButton has action with a method name
        XCTAssertTrue(shareButtonActions.contains("shareRenderedImage"))
        
    }
    
    //should pass
    func testTitleOfShareButton() throws {
        let shareButton: UIButton = sut.addShareButton
        
        XCTAssertTrue(shareButton.titleLabel?.text == "Share")
    }
    
    
    //MARK: - TEST METHODS FOR EQUATIONTEXTFIELD (UITEXTFIELD)
    
    func testReturnKeyOfEquationTextField() throws {
        let eqTextField = sut.equationTextField
        XCTAssertEqual(eqTextField.returnKeyType, UIReturnKeyType.go)
    }
    
    func testSecuredEntryOfEquationTextField() throws {
        let eqTextField = sut.equationTextField
        XCTAssertFalse(eqTextField.isSecureTextEntry)
        XCTAssertEqual(eqTextField.autocapitalizationType, UITextAutocapitalizationType.none)
    }
    
    
    
    //MARK: - ASYNCHRONOUS TEST
    func testValidWikimediaRESTAPICall() throws {
        let urlComp = URLComponents(string: "https://wikimedia.org/api/rest_v1/media/math/check/tex")!
        let body = ["q": "a^2 + b^2 = c^2"]
        
        var request = URLRequest(url: urlComp.url!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")  // header
        request.setValue("PLEASE_PUT_AN_EMAIL_ID", forHTTPHeaderField: "User-Agent")  // header
        
        let promise = expectation(description: "Status code: 200")
        
        
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
                return
            } else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 200 {
                    // 2
                    if let hashValue = (response as? HTTPURLResponse)?.allHeaderFields["x-resource-location"] as? String {
                        promise.fulfill()
                        self.wikiHash = hashValue
                        print("WWWWWWWWWWWWWWW------\(String(describing: self.wikiHash))")
                        
                    }
                    
                } else {
                    XCTFail("Status code: \(statusCode)")
                }
            }
        }
        dataTask.resume()
        // 3
        wait(for: [promise], timeout: 5)
        
    }
    
    
    
}
