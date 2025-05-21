//
//  NewsViewModel.swift
//  NewsPoint
//
//  Created by Mohamed Ashik Buhari on 19/05/25.
//

import Foundation

class NewsViewModel {
    
    static let shared = NewsViewModel(apiService: APIService())

    // MARK: - Properties
    private let apiService: APIServiceProtocol
    private(set) var articles: [Article] = [] {
        didSet {
            reloadTableView?()
        }
    }

    // MARK: Callbacks
    var reloadTableView: (() -> Void)?
    var showError: ((String) -> Void)?
    var isLoading: ((Bool) -> Void)?

    // MARK: - Initialization
    private init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }

    // MARK: - fetchNews
    func fetchNews(page: Int, pageSize: Int,completion: @escaping (Bool) -> Void) {
        isLoading?(true)
        apiService.fetchNews(page: page, pageSize: pageSize) { result in
            DispatchQueue.main.async {
                self.isLoading?(false)
                switch result {
                case .success(let articles):
                    NewsManager.shared.articles = articles
                    self.articles = articles
                    completion(true)
                case .failure(let error):
                    self.showError?(error.localizedDescription)
                    completion(false)
                }
            }
        }
    }

    var numberOfArticles: Int {
        return articles.count
    }

    func getArticle(at index: Int) -> Article? {
        guard index >= 0 && index < articles.count else { return nil }
        return articles[index]
    }

    func filterArticles(with searchText: String) -> [Article] {
        guard !searchText.isEmpty else { return articles }
        return articles.filter {
            $0.title?.lowercased().contains(searchText.lowercased()) ?? false
        }
    }
    
    func removeArticle(at index: Int) {
            guard index >= 0 && index < articles.count else { return }
            articles.remove(at: index)
            NewsManager.shared.articles.remove(at: index)
        }
}
