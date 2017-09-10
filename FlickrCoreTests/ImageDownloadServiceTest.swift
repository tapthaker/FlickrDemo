import XCTest
@testable import FlickrCore

class ImageDownloadServiceTest: XCTestCase {

    var downloadService: ImageDownloadService!
    var cache: NSCache<NSString, UIImage>!

    override func setUp() {
        super.setUp()
        let sessionConfiguration = URLSessionConfiguration.default
        let apiClient = APIClient(sessionConfiguration: sessionConfiguration)
        cache = NSCache<NSString, UIImage>()
        cache.countLimit = 10
        downloadService = ImageDownloadService(apiClient: apiClient,
                                               cache: cache,
                                               fileManager: FileManager.default)
    }

    func testDownloadImage() {
        let photo = Photo(farm: 5,
                          server: "4334",
                          id: "37125331885",
                          secret: "67c4632a38")

        let url = photo.createURL()

        let expectation = self.expectation(description: "Should Download Image")

        downloadService.download(url: url, uniqueKey: "ABCD", onCompletion: { (image) in
            expectation.fulfill()
        }) { (error) in
            XCTFail()
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10, handler: nil)
    }

    func testGetImageFromCache() {
        let image = UIImage()
        cache.setObject(image, forKey: "QWERTY" as NSString)
        let url = URL(string: "https://www.google.com")

        let expectation = self.expectation(description: "Should Get Image from Cache")

        downloadService.download(url: url!, uniqueKey: "QWERTY", onCompletion: { (downloadedImage) in
            XCTAssertEqual(image, downloadedImage)
            expectation.fulfill()
        }) { (error) in
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func testCancelDownload() {
        let photo = Photo(farm: 5,
                          server: "4365",
                          id: "36312087663",
                          secret: "45f581167b")

        let url = photo.createURL()

        let expectation = self.expectation(description: "Cancel Download")
        downloadService.download(url: url, uniqueKey: photo.id, onCompletion: { (image) in
            expectation.fulfill()
            XCTFail()
        }) { (error) in
            expectation.fulfill()
        }

        downloadService.cancel(uniqueKey: photo.id)

        self.waitForExpectations(timeout: 1, handler: nil)
    }
}
