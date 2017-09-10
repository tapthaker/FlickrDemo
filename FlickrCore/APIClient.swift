import Foundation

public typealias OnFailure = (APIError) -> Void

public enum APIError: Error {
    case Unknown
    case Foundation(Error)
    case Parsing
    case DownloadFailed
}

func notifyOnMainThread(_ execute: @escaping @autoclosure () -> Void) {
    DispatchQueue.main.async {
        execute()
    }
}

class  APIClient {
    private let session: URLSession

    init(sessionConfiguration: URLSessionConfiguration) {
        session = URLSession(configuration: sessionConfiguration)
    }

    func executeGET<T: Decodable>(url: URL,
                                  params: [String: String],
                                  onSuccess: @escaping (T) -> Void,
                                  onFailure: @escaping OnFailure) -> URLSessionTask {
        let urlRequest = createGETRequest(url: url, params: params)

        let dataTask = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in

            if let apiError = error {
                notifyOnMainThread(onFailure(APIError.Foundation(apiError)))
                return
            }

            guard response != nil else {
                notifyOnMainThread(onFailure(APIError.Unknown))
                return
            }

            do {
                if let parsedObject = try data?.decode(type: T.self) {
                    notifyOnMainThread(onSuccess(parsedObject))
                } else {
                    notifyOnMainThread(onFailure(APIError.Unknown))
                }
            } catch {
                notifyOnMainThread(onFailure(APIError.Parsing))
            }

        })

        dataTask.resume()
        
        return dataTask
    }

    func download(url: URL,
                  finalLocation: URL,
                  fileManager: FileManager,
                  onSuccess: @escaping (URL) -> Void,
                  onFailure: @escaping OnFailure) -> URLSessionDownloadTask {
        let downloadTask = session.downloadTask(with: url, completionHandler: { (location, response, error) in

            guard let tempFileLocation = location else {
                notifyOnMainThread(onFailure(APIError.DownloadFailed))
                return
            }
            do {
                try fileManager.moveItem(at: tempFileLocation, to: finalLocation)
                notifyOnMainThread(onSuccess(finalLocation))
            } catch {
                notifyOnMainThread(onFailure(APIError.DownloadFailed))
            }
        })

        downloadTask.resume()

        return downloadTask
    }

    private func createGETRequest(url: URL, params: [String: String]) -> URLRequest {
        let fullURL = url.appendingGETParams(params: params)
        var request = URLRequest(url: fullURL)
        request.httpMethod = "GET"
        return request
    }

}

extension Data {
    func decode<T: Decodable>(type: T.Type) throws -> T {
        return try JSONDecoder().decode(T.self, from: self)
    }
}

extension URL {
    func appendingGETParams(params: [String: String]) -> URL {
        let getParamsString = params.map { (key,value) -> String? in
            return value.urlEncoded.map({ "\(key)=\($0)" })

            }.flatMap({$0})
            .reduce("?") {(result, current) in
                return "\(result)&\(current)"
        }

        return URL(string: self.absoluteString + getParamsString)!
    }
}
extension String {
    var urlEncoded: String? {
        get {
            return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        }
    }
}

