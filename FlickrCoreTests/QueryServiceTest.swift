import XCTest
@testable import FlickrCore

class QueryServiceTest: XCTestCase {

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
