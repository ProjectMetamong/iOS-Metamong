//
//  ExerciseCamViewController.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/23.
//

import UIKit
import AVKit
import SnapKit

class ExerciseCamViewController: UIViewController {
    
    // MARK: - Properties
    
    lazy var camVideo: AVPlayer = {
        let videoURL = URL(fileURLWithPath: Bundle.main.path(forResource: "test", ofType: "mp4")!)
        let player = AVPlayer(url: videoURL)
        player.play()
        return player
    }()
    
    lazy var camVideoLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer(player: self.camVideo)
        layer.frame = view.bounds
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    lazy var stopButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = cornerRadius
        button.backgroundColor = .red
        button.setTitle("종료", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        button.addTarget(self, action: #selector(self.handleStopButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var progressBar: UISlider = {
        let slider = UISlider()
        slider.setThumbImage(UIImage(), for: .normal)
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.tintColor = .white
        slider.value = 0
        return slider
    }()
    
    var timeObserver: Any?
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        self.view.layer.addSublayer(camVideoLayer)
        self.view.addSubview(self.stopButton)
        self.view.addSubview(self.progressBar)
            
        self.timeObserver = self.camVideo.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.01, preferredTimescale: 600), queue: DispatchQueue.main) { CMTime in
            if self.camVideo.currentItem?.status == .readyToPlay {
                let duration = CMTimeGetSeconds((self.camVideo.currentItem?.asset.duration)!)
                let currentTime = CMTimeGetSeconds((self.camVideo.currentTime()))
                let progress = Float(currentTime / duration) * 100
                self.progressBar.value = progress
            }
        }
        
        self.stopButton.snp.makeConstraints {
            $0.right.equalTo(self.view.snp.right).offset(-15)
            $0.bottom.equalTo(self.view.snp.bottom).offset(-30)
            $0.height.equalTo(50)
            $0.width.equalTo(100)
        }
        
        self.progressBar.snp.makeConstraints {
            $0.top.equalTo(self.view.snp.topMargin).offset(15)
            $0.left.equalTo(self.view.snp.left).offset(15)
            $0.right.equalTo(self.view.snp.right).offset(-15)
        }
    }
    
    // MARK: - Actions
    
    @objc func handleStopButtonTapped() {
        self.camVideo.removeTimeObserver(self.timeObserver!)
        self.timeObserver = nil
        self.navigationController?.popToViewController(ofClass: DetailViewController.self)
    }
}
