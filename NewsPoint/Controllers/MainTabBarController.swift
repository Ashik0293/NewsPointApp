//
//  ViewController.swift
//  NewsPoint
//
//  Created by Mohamed Ashik Buhari on 19/05/25.
//

import UIKit


class MainTabBarController: UIViewController {
    
    @IBOutlet weak var viewForTab: UIView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var homeImage: UIImageView!
    
    @IBOutlet weak var searchImage: UIImageView!
    
    @IBOutlet weak var personImage: UIImageView!
    
   
    private var currentTabIndex: Int = 0
    
    
    let sharedNewsViewModel = NewsViewModel.shared

  
    let reachability = try! Reachability()
    
    var offlineAlert: UIAlertController?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        designableTabBar()
       // setupSwipeGestures()
//
//        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
//            self.goHome()
//        }
        
        DispatchQueue.main.async{
            self.goHome()
        }
        
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

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

            do {
                try reachability.startNotifier()
            } catch {
                print("Could not start notifier")
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

            self.offlineAlert = alert
            present(alert, animated: true)
        }

        func dismissOfflineAlert() {
            if let alert = offlineAlert {
                alert.dismiss(animated: true) {
                    self.offlineAlert = nil
                }
            }
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            reachability.stopNotifier()
        }
    
    private func setupSwipeGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
    
    
    func refreshCurrentTab() {
        switch currentTabIndex {
        case 0:
            goHome()
        case 1:
            loadSearch()
        case 2:
            loadProfile()
        default:
            break
        }
    }

    
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            if currentTabIndex < 2 {
                currentTabIndex += 1
                changeTab(to: currentTabIndex)
            }
        } else if gesture.direction == .right {
            if currentTabIndex > 0 {
                currentTabIndex -= 1
                changeTab(to: currentTabIndex)
            }
        }
    }

    
    private func changeTab(to index: Int) {
        guard let tab = TabEnum(rawValue: index) else { return }
        
        resetAllIcons()
        animateTabIcon(tab.imageView)

        switch tab {
        case .home:
            goHome()
        case .search:
            loadSearch()
        case .profile:
            loadProfile()
        }
    }

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func designableTabBar(){
        viewForTab.layer.cornerRadius = viewForTab.frame.size.height / 2
        viewForTab.clipsToBounds = true
    }
    
    @IBAction func onClickTabBar(_ sender: UIButton) {
        
        guard let tab = TabEnum(rawValue: sender.tag) else { return }
        currentTabIndex = sender.tag
        resetAllIcons()
        
        if let imageView = tab.imageView {
            animateTabIcon(imageView)
        }
        
        switch tab {
        case .home:
            goHome()
        case .search:
            loadSearch()
        case .profile:
            loadProfile()
        }
       
    }
    
    
    private func goHome(){
        guard let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else { return }
        //homeVC.viewModel = sharedNewsViewModel
        addChildViewController(homeVC, to: contentView)
    }
    
    
    private func loadSearch() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else { return }
       // vc.viewModel = sharedNewsViewModel
        addChildViewController(vc, to: contentView)
    }

    private func loadProfile() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController else { return }
        addChildViewController(vc, to: contentView)
    }
    
    func resetAllIcons() {
        UIView.animate(withDuration: 0.3) {
            self.homeImage.transform = .identity
            self.searchImage.transform = .identity
            self.personImage.transform = .identity
        }
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
    
    
    func animateTabIcon(_ imageView: UIImageView?) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut) {
            //imageView?.tintColor = color
            imageView?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
    }
}

