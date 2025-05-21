//
//  APIService.swift
//  NewsPointNewsPoint
//
//  Created by Mohamed Ashik Buhari on 19/05/25.
//


import Alamofire

protocol APIServiceProtocol {
    func fetchNews(page: Int, pageSize: Int, completion: @escaping (Result<[Article], Error>) -> Void)
}


class APIService: APIServiceProtocol {
    private let baseURL = "https://newsapi.org/v2/top-headlines"
    private let apiKey = "5c4d841134d046c08b33ddd27ad8f7d8"
    
    func fetchNews(page: Int = 1, pageSize: Int = 5, completion: @escaping (Result<[Article], Error>) -> Void) {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "country", value: "us"),
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "pageSize", value: "\(pageSize)")
        ]
        
        guard let url = components?.url else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        
        // Remove cache for pagination (optional)
        URLCache.shared.removeCachedResponse(for: request)
        
        AF.request(request)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    guard let httpResponse = response.response,
                          (200...299).contains(httpResponse.statusCode) else {
                        let statusCode = response.response?.statusCode ?? -1
                        completion(.failure(APIError.httpError(statusCode)))
                        return
                    }
                    
                    do {
                        let decoded = try JSONDecoder().decode(NewsResponse.self, from: data)
                        completion(.success(decoded.articles))
                    } catch {
                        completion(.failure(APIError.noData))
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
