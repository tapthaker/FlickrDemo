import Foundation

class ImageDownloadService {

    let apiClient: APIClient
    let cache: NSCache<NSString, UIImage>
    var downloadTasks: [String: URLSessionDownloadTask] = [:]
    let fileManager: FileManager
    let tempDirectory: URL

    init(apiClient: APIClient, cache: NSCache<NSString, UIImage>, fileManager: FileManager) {
        self.apiClient = apiClient
        self.cache = cache
        self.fileManager = fileManager
        self.tempDirectory = fileManager.temporaryDirectory
    }

    func download(url: URL, uniqueKey: String,
                  onCompletion: @escaping (UIImage) -> Void,
                  onFailure: @escaping OnFailure) {

        if let image = cache.object(forKey: uniqueKey as NSString) {
            onCompletion(image)
            return
        }

        let finalLocation = tempDirectory.appendingPathComponent(uniqueKey)

        if let image = UIImage(fileLocation: finalLocation) {
            onCompletion(image)
            return
        }

        let urlSessonDownloadTask = apiClient.download(url: url,
                                                       finalLocation: finalLocation,
                                                       fileManager: fileManager,
                                                       onSuccess: { [weak self] (url) in
                                                        if let image = UIImage(fileLocation: url) {
                                                            let cost = Int(image.size.height) * Int(image.size.width)
                                                            self?.cache.setObject(image,
                                                                                  forKey: uniqueKey as NSString,
                                                                                  cost: cost)
                                                            onCompletion(image)
                                                        } else {
                                                            onFailure(APIError.DownloadFailed)
                                                        }
                                                        self?.downloadTasks.removeValue(forKey: uniqueKey)

        }) { (error) in
            onFailure(error)
        }
        downloadTasks[uniqueKey] = urlSessonDownloadTask
    }

    func cancel(uniqueKey: String) -> Void {
        downloadTasks[uniqueKey]?.cancel()
    }
}

fileprivate extension UIImage {
    convenience init?(fileLocation: URL) {
        do {
            let data = try Data(contentsOf: fileLocation)
            self.init(data: data)
        } catch {
            return nil
        }
    }
}
