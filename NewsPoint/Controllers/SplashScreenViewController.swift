//
//  LoginViewController.swift
//  NewsPoint
//
//  Created by Mohamed Ashik Buhari on 19/05/25.
//


import UIKit
import AVKit
import AVFoundation

class SplashScreenViewController: UIViewController {
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    
    
    @IBOutlet weak var SplashView: VideoPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playSplashVideo()
        
    }
    
    
    private func playSplashVideo() {
        guard let path = Bundle.main.path(forResource: "SplashVideo", ofType: "mp4") else {
            print("Video file not found")
            checkLoginState()
            return
        }
        
        let url = URL(fileURLWithPath: path)
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        SplashView.player = player
        SplashView.playerLayer.videoGravity = .resizeAspectFill
       
        
        
        player?.play()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(videoDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
    }
    
    @objc private func videoDidFinishPlaying() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.checkLoginState()
        }
    }
    
    
    private func checkLoginState() {
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if isLoggedIn {
            let homeVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
            self.navigationController?.pushViewController(homeVC, animated: true)
        } else {
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            self.navigationController?.pushViewController(loginVC, animated: true)
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
}
