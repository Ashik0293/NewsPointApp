//
//  SearchListCollectionViewCell.swift
//  NewsPoint
//
//  Created by Mohamed Ashik Buhari on 19/05/25.
//

import UIKit
import Kingfisher


class SearchListCollectionViewCell: UICollectionViewCell {
    
    
    
    @IBOutlet weak var newsImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    

    func configure(with article: Article) {
        titleLabel.text = article.title ?? "No title available"
        newsImageView.kf.indicatorType = .activity
        if let imageUrlString = article.urlToImage,
           let imageUrl = URL(string: imageUrlString) {
            let placeholder = UIImage(named: "placeholder")
            newsImageView.kf.setImage(with: imageUrl, placeholder: placeholder, options: [.transition(.fade(0.3)), .cacheOriginalImage])
        } else {
            newsImageView.image = UIImage(named: "placeholder")
        }
    }

}
