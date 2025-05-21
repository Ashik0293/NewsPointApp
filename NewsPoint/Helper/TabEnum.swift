//
//  TabEnum.swift
//  NewsPoint
//
//  Created by Mohamed Ashik Buhari on 19/05/25.
//


import UIKit

enum TabEnum: Int {
    case home = 0, search, profile
        
    var imageView: UIImageView? {
        let vc = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        switch self {
        case .home: return vc?.homeImage
        case .search: return vc?.searchImage
        case .profile: return vc?.personImage
        }
    }
    
}
