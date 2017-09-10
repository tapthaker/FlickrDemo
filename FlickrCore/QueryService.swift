import Foundation

class QueryService {
    
    private static let apiKey = ""
    private let url = URL(string: "https://api.flickr.com/services/rest/")!
    let defaultParams = [ "method" : "flickr.photos.search",
                          "api_key": apiKey,
                          "format": "json",
                          "nojsoncallback": "1",
                          "safe_search" : "1"]

    private let apiClient: APIClient


    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func searchImages(query: String,
                      onSuccess: @escaping (ImageSearchResponse?) -> Void,
                      onFailure: @escaping OnFailure) -> URLSessionTask {

        var params = defaultParams
        params["text"] = query

        return self.apiClient.executeGET(url: url,
                                         params: params,
                                         onSuccess: onSuccess,
                                         onFailure: onFailure)
    }
}
