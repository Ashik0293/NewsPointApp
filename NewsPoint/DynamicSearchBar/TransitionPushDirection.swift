//
//  TransitionPushDirection.swift
//  NewsPoint
//
//  Created by Mohamed Ashik Buhari on 20/05/25.
//

import UIKit

public enum TransitionPushDirection {
    case fromBottom
    case fromLeft
    case fromRight
    case fromTop

    public var coreAnimationConstant: CATransitionSubtype {
        switch self {
        case .fromBottom:
            return CATransitionSubtype.fromBottom
        case .fromTop:
            return CATransitionSubtype.fromTop
        case .fromLeft:
            return CATransitionSubtype.fromLeft
        case .fromRight:
            return CATransitionSubtype.fromRight
        }
    }
}
