import Foundation

public typealias OnFailure = (APIError) -> Void

public enum APIError: Error {
    case Unknown
    case Foundation(Error)
    case Parsing
}

class  APIClient {
    private let session: URLSession

    init(sessionConfiguration: URLSessionConfiguration) {
        session = URLSession(configuration: sessionConfiguration)
    }

    func executeGET<T: Decodable>(url: URL,
                    params: [String: String],
                    onSuccess: @escaping (T?) -> Void,
                    onFailure: @escaping OnFailure) -> URLSessionTask {
        let urlRequest = createGETRequest(url: url, params: params)

        let dataTask = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in

            if let apiError = error {
                onFailure(APIError.Foundation(apiError))
                return
            }

            guard response != nil else {
                onFailure(APIError.Unknown)
                return
            }

            do {
                let parsedObject = try data?.decode(type: T.self)
                onSuccess(parsedObject)
            } catch {
                onFailure(APIError.Parsing)
            }

        })

        dataTask.resume()
        
        return dataTask
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
