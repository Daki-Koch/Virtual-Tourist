//
//  Virtual_TouristTests.swift
//  Virtual TouristTests
//
//  Created by David Koch on 17.12.22.
//

import XCTest
@testable import Virtual_Tourist

final class Virtual_TouristTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        
    }

    override func tearDownWithError() throws {
        
        try super.tearDownWithError()
        
        
    }
    
    func testImageDownloads() throws{
        
        FlickrClient.getImageCollectionRequest(latitute: 47.37, longitude: 8.54) { result, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            print(result)
        }
    }

    

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
