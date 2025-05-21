//
// ArticleHelper.swift
//  NewsPoint
//
//  Created by Mohamed Ashik Buhari on 20/05/25.
//



import UIKit
import Kingfisher

struct ArticleHelper {
    
    static func formatContent(_ content: String?) -> String {
        guard let rawContent = content else {
            return "No Content available"
        }
        
        let cleanedContent = rawContent.components(separatedBy: "[+").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        return cleanedContent
    }

    
    static func formatAuthorDate(publishedAt: String?, author: String?) -> String {
        let authorName = author ?? "Unknown author"
        
        guard let publishedAt = publishedAt else {
            return "Date not available  |  \(authorName)"
        }
        
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: publishedAt) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "dd-MM-yyyy"
            return "\(displayFormatter.string(from: date))  |  \(authorName)"
        } else {
            return "Invalid date  |  \(authorName)"
        }
    }
    
    @MainActor static func loadImage(into imageView: UIImageView, from urlString: String?, shimmerHandler: (() -> Void)? = nil) {
        imageView.kf.indicatorType = .activity
        if let urlString = urlString, let url = URL(string: urlString) {
            shimmerHandler?()
            let placeholder = UIImage(named: "placeholder")
            imageView.kf.setImage(
                with: url,
                placeholder: placeholder,
                options: [.transition(.fade(0.3)), .cacheOriginalImage]
            ) { _ in
                shimmerHandler?()
            }
        } else {
            imageView.image = UIImage(named: "placeholder")
        }
    }
}
