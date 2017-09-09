//
//  FlickrCoreTests.swift
//  FlickrCoreTests
//
//  Created by Tapan Thaker on 09/09/17.
//  Copyright © 2017 tapthaker. All rights reserved.
//

import XCTest
@testable import FlickrCore

class FlickrCoreTests: XCTestCase {

    var queryService: QueryService!
    
    override func setUp() {
        super.setUp()
        let sessionConfiguration = URLSessionConfiguration.default
        let apiClient = APIClient(sessionConfiguration: sessionConfiguration)
        queryService = QueryService(apiClient: apiClient)
    }
    
    func testSearchImages() {
        let expectation = self.expectation(description: "Flickr API call")
            queryService.searchImages(query: "Husky", onSuccess: { (response) in
                XCTAssertNotNil(response)
                expectation.fulfill()
            }, onFailure: { (error) in
                dump(error)
                XCTFail("Flickr API call failed")
                expectation.fulfill()
            })

        self.wait(for: [expectation], timeout: 10)
        }
    }
