import XCTest
@testable import FlickrCore

class QueryServiceTest: XCTestCase {

    var queryService: QueryService!

    override func setUp() {
        super.setUp()
        let sessionConfiguration = URLSessionConfiguration.default
        let apiClient = APIClient(sessionConfiguration: sessionConfiguration)
        queryService = QueryService(query: "Husky", apiClient: apiClient)
    }

    func testSearchImages() {
        let expectation = self.expectation(description: "Flickr API call")
        queryService.nextImages(onSuccess: { (response) in
            XCTAssertNotNil(response)
            expectation.fulfill()
        }, onFailure: { (error) in
            dump(error)
            XCTFail("Flickr API call failed")
            expectation.fulfill()
        })

        self.wait(for: [expectation], timeout: 10)
    }

    func testIgnoreIfRequestAlreadyInProgress() {
        let expectation = self.expectation(description: "Flickr API call")
        queryService.nextImages(onSuccess: { (response) in
            XCTAssertNotNil(response)
            expectation.fulfill()
        }, onFailure: { (error) in
            dump(error)
            XCTFail("Flickr API call failed")
            expectation.fulfill()
        })

        queryService.nextImages(onSuccess: { (response) in
            XCTFail("Should not make another request")
        }) { (error) in
            XCTFail("Should not make another request")
        }

        self.wait(for: [expectation], timeout: 10)
    }
}
