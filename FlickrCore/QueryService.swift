import Foundation

public class QueryService {
    
    private static let apiKey = ""
    private let url = URL(string: "https://api.flickr.com/services/rest/")!
    let defaultParams = [ "method" : "flickr.photos.search",
                          "api_key": apiKey,
                          "format": "json",
                          "nojsoncallback": "1",
                          "safe_search" : "1"]

    private let apiClient: APIClient
    private let query: String
    private var numberOfPages: Int?
    private var currentPage = 0
    private var onGoingSearch: URLSessionTask? = nil

    public convenience init(query: String) {
        let apiClient = APIClient(sessionConfiguration: URLSessionConfiguration.default)
        self.init(query: query,
                  apiClient: apiClient)
    }


    init(query: String, apiClient: APIClient) {
        self.query = query
        self.apiClient = apiClient
    }

    public func nextImages(onSuccess: @escaping ([Photo]) -> Void,
                                                onFailure: @escaping OnFailure) {

        guard onGoingSearch == nil || onGoingSearch?.state == .completed else {
            return
        }

        currentPage = currentPage + 1

        var params = defaultParams
        params["text"] = query
        params["page"] = "\(currentPage)"

        let successBlock = { [weak self] (response: ImageSearchResponse) in
            self?.currentPage = response.photos.page
            self?.numberOfPages = response.photos.pages
            onSuccess(response.getPhotos())
        }
        onGoingSearch = self.apiClient.executeGET(url: url,
                                                  params: params,
                                                  onSuccess: successBlock,
                                                  onFailure: onFailure)
    }
}
