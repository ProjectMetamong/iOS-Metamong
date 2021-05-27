//
//  ExerciseViewController.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/22.
//

import UIKit
import AVKit
import SnapKit
import Vision

class ExerciseReferenceViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: ExerciseReferenceViewModel = ExerciseReferenceViewModel()
    
    private var referencePoseEdgePaths = UIBezierPath()
    private var referencePosePointPaths = UIBezierPath()
    
    private var startingTime: Int64?
    
    lazy var fakeCaptureSession: AVCaptureSession = {
        let session = AVCaptureSession()
    
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return session }
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return session }
        guard session.canAddInput(deviceInput) else { return session }
        session.addInput(deviceInput)
        session.commitConfiguration()
        
        return session
    }()
    
    lazy var fakeCaptureLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer()
        layer.frame = view.bounds
        layer.videoGravity = .resizeAspectFill
        layer.session = self.fakeCaptureSession
        return layer
    }()
    
    lazy var referenceVideo: AVPlayer = {
        let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileUrl = documentsDirectoryUrl?.appendingPathComponent("test.mov")
        let player = AVPlayer(url: fileUrl!)
        return player
    }()
    
    lazy var referenceVideoLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer(player: self.referenceVideo)
        
        let rotate = CGAffineTransform(rotationAngle: degreeToRadian(90))
        let flip = CGAffineTransform(scaleX: -1, y: 1)
        let rotateAndFlip = rotate.concatenating(flip)
        layer.setAffineTransform(rotateAndFlip)
        
        layer.frame = view.bounds
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    lazy var overlayLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.frame = view.bounds
        layer.contentsGravity = .resizeAspectFill
        layer.addSublayer(referencePoseEdgeLayer)
        layer.addSublayer(referencePosePointLayer)
        return layer
    }()
    
    lazy var referencePosePointLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.frame = view.bounds
        layer.lineWidth = posePointWidth
        layer.strokeColor = referencePoseStrokeColor
        layer.fillColor = referencePosePointColor
        layer.contentsGravity = .resizeAspectFill
        return layer
    }()
    
    lazy var referencePoseEdgeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.frame = view.bounds
        layer.lineWidth = poseEdgeWidth
        layer.strokeColor = referencePoseStrokeColor
        layer.lineCap = .round
        layer.contentsGravity = .resizeAspectFill
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
    
    lazy var startButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = cornerRadius
        button.backgroundColor = .systemGreen
        button.setTitle("시작하기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        button.addTarget(self, action: #selector(self.handleStartButtonTapped), for: .touchUpInside)
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
    
    lazy var referenceDisplayTimer: Timer = {
        let timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(self.displayReference), userInfo: nil, repeats: true)
        return timer
    }()
    
    var timeObserver: Any?
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
        
        self.referenceVideo.play()
        self.startingTime = Date().toMilliSeconds
        self.referenceDisplayTimer.fire()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.referenceVideo.removeTimeObserver(self.timeObserver!)
        self.timeObserver = nil
        self.referenceDisplayTimer.invalidate()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        self.view.layer.addSublayer(self.fakeCaptureLayer)
        self.view.layer.addSublayer(self.referenceVideoLayer)
        self.view.layer.addSublayer(self.overlayLayer)
        self.view.addSubview(self.stopButton)
        self.view.addSubview(self.startButton)
        self.view.addSubview(self.progressBar)
            
        self.timeObserver = self.referenceVideo.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.01, preferredTimescale: 600), queue: DispatchQueue.main) { CMTime in
            if self.referenceVideo.currentItem?.status == .readyToPlay {
                let duration = CMTimeGetSeconds((self.referenceVideo.currentItem?.asset.duration)!)
                let currentTime = CMTimeGetSeconds((self.referenceVideo.currentTime()))
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
        
        self.startButton.snp.makeConstraints {
            $0.left.equalTo(self.view.snp.left).offset(15)
            $0.centerY.equalTo(self.stopButton.snp.centerY)
            $0.right.equalTo(self.stopButton.snp.left).offset(-15)
            $0.height.equalTo(50)
        }
        
        self.progressBar.snp.makeConstraints {
            $0.top.equalTo(self.view.snp.topMargin).offset(15)
            $0.left.equalTo(self.view.snp.left).offset(15)
            $0.right.equalTo(self.view.snp.right).offset(-15)
        }
    }
    
    func displayReferencePose(points : [VNHumanBodyPoseObservation.JointName : CGPoint?], edges: [Edge]) {
        self.referencePoseEdgePaths.removeAllPoints()
        self.referencePosePointPaths.removeAllPoints()
        
        for edge in edges {
            guard let from = points[edge.from]!, let to = points[edge.to]! else { continue }
            let path = UIBezierPath()
            path.move(to: from)
            path.addLine(to: to)
            self.referencePoseEdgePaths.append(path)
        }
        
        for (key, point) in points {
            guard let point = point else { continue }
            print("key : \(key.rawValue), x : \(point.x), y : \(point.y)")
            let path = UIBezierPath(center: point, radius: posePointRadius)
            self.referencePosePointPaths.append(path)
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.referencePoseEdgeLayer.path = self.referencePoseEdgePaths.cgPath
        self.referencePosePointLayer.path = self.referencePosePointPaths.cgPath
        CATransaction.commit()
    }
    
    // MARK: - Actions
    
    @objc func displayReference() {
        let time = Int(Date().toMilliSeconds - self.startingTime!)
        if let codablePose = self.viewModel.poseSequence.poses[time] {
            let recordedBody = Pose(from: codablePose)
            recordedBody.buildPoseAndDisplay(for: self.fakeCaptureLayer, on: self.overlayLayer, completion: self.displayReferencePose(points:edges:))
        }
    }
    
    @objc func handleStopButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func handleStartButtonTapped() {
        self.referenceVideo.pause()
        let exerciseCamViewController = ExerciseCamViewController()
        
        exerciseCamViewController.hero.isEnabled = true
        
        self.navigationController?.hero.navigationAnimationType = .fade
        self.navigationController?.pushViewController(exerciseCamViewController, animated: true)
    }
}
