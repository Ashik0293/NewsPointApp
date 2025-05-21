//
//  ToastManager.swift
//  NewsPoint
//
//  Created by Mohamed Ashik Buhari on 21/05/25.
//

import UIKit

class Toast {
    
    static func show(message: String, in viewController: UIViewController, duration: TimeInterval = 2.0) {
        let toastContainer = UIView()
        toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastContainer.alpha = 0.0
        toastContainer.layer.cornerRadius = 10
        toastContainer.clipsToBounds = true
        
        let toastLabel = UILabel()
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.text = message
        toastLabel.numberOfLines = 0
        
        toastContainer.addSubview(toastLabel)
        viewController.view.addSubview(toastContainer)
        
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toastLabel.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: 12),
            toastLabel.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -12),
            toastLabel.topAnchor.constraint(equalTo: toastContainer.topAnchor, constant: 10),
            toastLabel.bottomAnchor.constraint(equalTo: toastContainer.bottomAnchor, constant: -10),
            
            toastContainer.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            toastContainer.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            toastContainer.leadingAnchor.constraint(greaterThanOrEqualTo: viewController.view.leadingAnchor, constant: 40),
            toastContainer.trailingAnchor.constraint(lessThanOrEqualTo: viewController.view.trailingAnchor, constant: -40),
        ])
        
        UIView.animate(withDuration: 0.3, animations: {
            toastContainer.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.5
            }) { _ in
                toastContainer.removeFromSuperview()
            }
        }
    }
}
