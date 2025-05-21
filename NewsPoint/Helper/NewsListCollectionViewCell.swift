//
//  NewsListCollectionViewCell.swift
//  NewsPoint
//
//  Created by Mohamed Ashik Buhari on 19/05/25.
//

import UIKit
import Kingfisher


class NewsListCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var newsImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var newsContent: UILabel!
    
    @IBOutlet weak var authorNewsTime: UILabel!
    
    
    
    func configure(with article: Article) {
        DispatchQueue.main.async{ [self] in
            titleLabel.text = article.title ?? "No title available"
            newsContent.text = ArticleHelper.formatContent(article.content)
            authorNewsTime.text = ArticleHelper.formatAuthorDate(publishedAt: article.publishedAt, author: article.author)
            
            
            ArticleHelper.loadImage(into: newsImageView, from: article.urlToImage) { [weak self] in
                self?.startShimmering()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.stopShimmering()
                }
            }
        }
    }
    
}
