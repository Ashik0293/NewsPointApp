//
//  shimmerEffect.swift
//  NewsPoint
//
//  Created by Mohamed Ashik Buhari on 20/05/25.
//


import UIKit

extension UIView {
    private enum ShimmerConstants {
        static let animationKey = "shimmer"
        static let gradientName = "shimmerGradient"
    }
    
    func startShimmering() {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = ShimmerConstants.gradientName
        gradientLayer.frame = self.bounds
        
        
        let lightColor = UIColor.white.cgColor
        let alphaColor = UIColor.white.withAlphaComponent(0.7).cgColor
        gradientLayer.colors = [alphaColor, lightColor, alphaColor]
        
        
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.locations = [0.0, 0.5, 1.0]
        
       
        self.layer.mask = gradientLayer
        
       
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1.2
        animation.repeatCount = .infinity
        
        
        gradientLayer.add(animation, forKey: ShimmerConstants.animationKey)
    }
    
    func stopShimmering() {
        self.layer.mask?.removeFromSuperlayer()
        self.layer.mask = nil
    }
    
    func isShimmering() -> Bool {
        return self.layer.mask?.name == ShimmerConstants.gradientName
    }
}
