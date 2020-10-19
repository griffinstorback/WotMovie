//
//  EncodingTests.swift
//  WotMovieTests
//
//  Created by Griffin Storback on 2020-10-11.
//

import XCTest
@testable import WotMovie

class EncodingTests: XCTestCase {
    
    // the test url
    var url: URL!
    
    // encoding "parameters", then decoding into MockJSON object, should end up equal to "mockJSON"
    var parameters: Parameters!
    var mockJSON: MockJSON!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        guard let url = URL(string: "https://www.google.com/") else {
            XCTAssertTrue(false, "Could not instantiate url")
            return
        }
        
        self.url = url
        self.mockJSON = MockJSON(id: 1, name: "Griffin", email: "griffinstorback@gmail.com")
        self.parameters = [
            "UserID": 1,
            "Name": "Griffin",
            "Email": "griffinstorback@gmail.com"
        ]
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
    }

    func testJSONEncoding() {
        var goodURLRequest = URLRequest(url: url)
        
        do {
            try JSONParameterEncoder.encode(urlRequest: &goodURLRequest, with: parameters)
            let decodedBody: MockJSON = try JSONDecoder().decode(MockJSON.self, from: goodURLRequest.httpBody!)
            
            XCTAssertEqual(decodedBody, mockJSON)
        } catch {
            
        }
    }
    
    func testJSONEncodingThrowsError() {
        var urlRequest = URLRequest(url: url)
        
        var badParameters = Parameters()
        let badString = String(bytes: [0xD8, 0x00] as [UInt8], encoding: String.Encoding.utf16BigEndian)
        badParameters["badField"] = badString
        
        var thrownError: Error?
        
        XCTAssertThrowsError(try JSONParameterEncoder.encode(urlRequest: &urlRequest, with: badParameters), "JSONParameterEncoder did not throw an error") { error in
            thrownError = error
        }
        
        if let thrownError = thrownError as? NetworkError {
            XCTAssertEqual(thrownError, .encodingFailed)
        } else {
            XCTAssertTrue(false, "either error wasn't thrown, or thrownError is not of type NetworkError")
        }
    }
    
    func testURLEncoding() {
        var goodURLRequest = URLRequest(url: url)
        
        do {
            try URLParameterEncoder.encode(urlRequest: &goodURLRequest, with: parameters)
            
            guard let fullURL = goodURLRequest.url else {
                XCTAssertTrue(false, "URLRequest.url is nil")
                return
            }
            let expectedURL = "https://www.google.com/?Name=Griffin&Email=griffinstorback%2540gmail.com&UserID=1"
            
            XCTAssertEqual(fullURL.absoluteString.sorted(), expectedURL.sorted())
        } catch {
            
        }
    }
    
    func testURLEncodingThrowsError() {
        var badURLRequest = URLRequest(url: url)
        badURLRequest.url = nil
        
        var thrownError: Error?
        
        XCTAssertThrowsError(try URLParameterEncoder.encode(urlRequest: &badURLRequest, with: parameters), "URLParameterEncoder did not throw an error") { error in
            thrownError = error
        }
        
        if let thrownError = thrownError as? NetworkError {
            XCTAssertEqual(thrownError, .missingURL)
        } else {
            XCTAssertTrue(false, "either error wasn't thrown, or thrownError is not of type NetworkError")
        }
    }
}
