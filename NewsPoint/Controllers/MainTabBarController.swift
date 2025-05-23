//
//  ViewController.swift
//  NewsPoint
//
//  Created by Mohamed Ashik Buhari on 19/05/25.
//

import UIKit
import SwiftUICore

class MainTabBarController: UIViewController {
    
    
    // MARK: - Outlets
    @IBOutlet private weak var viewForTab: UIView!
    
    @IBOutlet private weak var contentView: UIView!
    
    @IBOutlet private weak var homeImage: UIImageView!
    
    @IBOutlet private weak var searchImage: UIImageView!
    
    @IBOutlet private weak var personImage: UIImageView!
    
    
    // MARK: - Properties
    private var currentTabIndex: Int = TabEnum.home.rawValue
    private let sharedNewsViewModel = NewsViewModel.shared
    private let reachability = try! Reachability()
    private var offlineAlert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupReachability()
        goHome()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reachability.stopNotifier()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        reachability.stopNotifier()
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    // MARK: Actions
    @IBAction func onClickTabBar(_ sender: UIButton) {
        changeTab(to: sender.tag)
    }
    
    
    
}

// MARK: - UI Setup
private extension MainTabBarController {
    func setupUI() {
        navigationController?.isNavigationBarHidden = true
        designableTabBar()
    }
    
    func designableTabBar() {
        viewForTab.layer.cornerRadius = viewForTab.frame.size.height / 2
        viewForTab.clipsToBounds = true
    }
}


// MARK: - Tab Management
private extension MainTabBarController {
    func changeTab(to index: Int) {
        guard let tab = TabEnum(rawValue: index) else {
            print("Invalid tab index: \(index). Defaulting to home.")
            changeTab(to: TabEnum.home.rawValue)
            return
        }
        
        currentTabIndex = index
        let imageView: UIImageView?
        let color: UIColor
        switch index {
        case TabEnum.home.rawValue:
            imageView = homeImage
        case TabEnum.search.rawValue:
            imageView = searchImage
        case TabEnum.profile.rawValue:
            imageView = personImage
        default:
            imageView = nil
            color = .white // Fallback color
        }
        
        resetAllIcons()
        animateTabIcon(imageView)
        refreshCurrentTab()
    }
    
    func refreshCurrentTab() {
        switch currentTabIndex {
        case TabEnum.home.rawValue:
            goHome()
        case TabEnum.search.rawValue:
            loadSearch()
        case TabEnum.profile.rawValue:
            loadProfile()
        default:
            print("Unexpected tab index: \(currentTabIndex)")
        }
    }
    
    func goHome() {
        guard let homeVC = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else {
            print("Failed to instantiate HomeViewController")
            return
        }
        addChildViewController(homeVC, to: contentView)
    }
    
    func loadSearch() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else {
            print("Failed to instantiate SearchViewController")
            return
        }
        addChildViewController(vc, to: contentView)
    }
    
    func loadProfile() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController else {
            print("Failed to instantiate ProfileViewController")
            return
        }
        addChildViewController(vc, to: contentView)
    }
    
    func addChildViewController(_ childVC: UIViewController, to containerView: UIView) {
        children.forEach {
            $0.willMove(toParent: nil)
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        }
        
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }
    
    func resetAllIcons() {
        UIView.animate(withDuration: 0.3) {
            self.homeImage.transform = .identity
            self.searchImage.transform = .identity
            self.personImage.transform = .identity
            self.homeImage.tintColor = .white
            self.searchImage.tintColor = .white
            self.personImage.tintColor = .white
        }
    }
    
    func animateTabIcon(_ imageView: UIImageView?) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        guard let imageView = imageView else { return }
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut) {
            //imageView.tintColor = color
            imageView.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
        }
    }
}


// MARK: - Network Handling
private extension MainTabBarController {
    func setupReachability() {
        reachability.whenUnreachable = { [weak self] _ in
            DispatchQueue.main.async {
                self?.showOfflineAlert()
            }
        }
        
        reachability.whenReachable = { [weak self] _ in
            DispatchQueue.main.async {
                self?.dismissOfflineAlert()
                self?.refreshCurrentTab()
            }
        }
    }
    
    func startReachabilityNotifier() {
        do {
            try reachability.startNotifier()
        } catch {
            print("Could not start reachability notifier: \(error)")
        }
    }
    
    func showOfflineAlert() {
        guard offlineAlert == nil else { return }
        
        let alert = UIAlertController(
            title: "No Internet",
            message: "You are offline. Please check your internet connection.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [weak self] _ in
            self?.dismissOfflineAlert()
            self?.refreshCurrentTab()
        }))
        
        offlineAlert = alert
        present(alert, animated: true)
    }
    
    func dismissOfflineAlert() {
        offlineAlert?.dismiss(animated: true) {
            self.offlineAlert = nil
        }
    }
}

