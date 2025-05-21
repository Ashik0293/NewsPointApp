//
//  Gradient.swift
//  NewsPoint
//
//  Created by Mohamed Ashik Buhari on 20/05/25.
//

import UIKit


@IBDesignable
class GradientLayer: UIView{
    
    @IBInspectable var topColor : UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.8470588326) {
        didSet{
            setNeedsLayout()
        }
    }
    @IBInspectable var bottomColor: UIColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1) {
        didSet{
            setNeedsLayout()
        }
    }
    
    var startPointX : CGFloat = 0
    var startPointY : CGFloat = 0
    var endPointX : CGFloat = 1
    var endPointY : CGFloat = 1
    
    override func layoutSubviews() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [topColor.cgColor,bottomColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: startPointX, y: startPointY)
        gradientLayer.endPoint = CGPoint(x: endPointX, y: endPointY)
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}


