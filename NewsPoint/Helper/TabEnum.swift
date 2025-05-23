//
//  TabEnum.swift
//  NewsPoint
//
//  Created by Mohamed Ashik Buhari on 19/05/25.
//


import UIKit

enum TabEnum: Int {
    case home = 0, search, profile
    
    var color: UIColor {
        switch self {
        case .home:
            return .red
        case .search:
            return .systemGreen
        case .profile:
            return .systemPurple
        }
    }
    
}
