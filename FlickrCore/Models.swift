import Foundation

fileprivate let apiClient = APIClient(sessionConfiguration: URLSessionConfiguration.default)

fileprivate let cache = NSCache<NSString, UIImage>()

fileprivate let imageDownloadService = ImageDownloadService(apiClient: apiClient, cache: cache, fileManager: FileManager.default)

public struct Photo: Decodable {
    let farm: Int
    let server: String
    let id: String
    let secret: String

    func createURL() -> URL {
        let urlString = "https://farm\(farm).static.flickr.com/\(server)/\(id)_\(secret).jpg"
        return URL(string: urlString)!
    }
}

public struct Photos: Decodable {
    let page: Int
    let pages: Int
    let photo: [Photo]
}

public struct ImageSearchResponse: Decodable {
    let photos: Photos
}


public extension Photo {
    func download(on imageView: UIImageView) {
        let url = createURL()

        imageView.backgroundColor = UIColor.red

        imageDownloadService.download(url: url, uniqueKey: id, onCompletion: { (image) in
            imageView.image = image
        }) { (error) in
            imageView.backgroundColor = UIColor.white
        }
    }

    public func cancel() {
        imageDownloadService.cancel(uniqueKey: id)
    }
}
