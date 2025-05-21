//
//  APIError.swift
//  NewsPoint
//
//  Created by Mohamed Ashik Buhari on 19/05/25.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case httpError(Int)
    case noData
    case encodingFailed(Error)
    case decodingFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .httpError(let code):
            return "HTTP Error with status code \(code)."
        case .noData:
            return "No data received from the server."
        case .encodingFailed(let err):
            return "Failed to encode JSON: \(err.localizedDescription)"
        case .decodingFailed:
            return "Failed to decode the server response."
        }
    }
}
