//
//  VideoPlayerView.swift
//  NewsPoint
//
//  Created by Mohamed Ashik Buhari on 21/05/25.
//

import UIKit
import AVFoundation

class VideoPlayerView: UIView {
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
 
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
 
    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
}
