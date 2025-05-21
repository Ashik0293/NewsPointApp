//
//  NewsManager.swift
//  NewsPoint
//
//  Created by Mohamed Ashik Buhari on 20/05/25.
//

import Foundation


class NewsManager {
    static let shared = NewsManager()
    
    private init() {}

    var articles: [Article] = []
}
