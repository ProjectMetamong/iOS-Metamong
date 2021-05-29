//
//  RecordConfirmViewController.swift
//  PoC UIKit
//
//  Created by 김정현 on 2021/05/28.
//

import UIKit
import AVKit
import SnapKit
import Vision
import RxSwift
import RxCocoa

class RecordConfirmViewController: UIViewController {

    // MARK: - Properties
    
    private let viewModel: RecordConfirmViewModel = RecordConfirmViewModel()
    
    // User Pose Related
    private var recordPoseEdgePaths = UIBezierPath()
    private var recordPosePointPaths = UIBezierPath()
    
    // Display Time Related
    private var displayStartTime: Int64 = Date().toMilliSeconds
    var timeObserver: Any?
    
    var disposeBag: DisposeBag = DisposeBag()
    
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
    
    lazy var recordVideo: AVPlayer = {
        let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileUrl = documentsDirectoryUrl?.appendingPathComponent("test.mov")
        let player = AVPlayer(url: fileUrl!)
        
        self.timeObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.01, preferredTimescale: 600), queue: DispatchQueue.main) { CMTime in
            if self.recordVideo.currentItem?.status == .readyToPlay {
                let duration = CMTimeGetSeconds((self.recordVideo.currentItem?.asset.duration)!)
                let currentTime = CMTimeGetSeconds((self.recordVideo.currentTime()))
                let progress = Float(currentTime / duration) * 100
                self.progressBar.value = progress
            }
        }

        return player
    }()
    
    lazy var recordVideoLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer(player: self.recordVideo)
        
        let rotate = CGAffineTransform(rotationAngle: 90.degreeToRadian)
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
        layer.addSublayer(recordPoseEdgeLayer)
        layer.addSublayer(recordPosePointLayer)
        return layer
    }()
    
    lazy var recordPosePointLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.frame = view.bounds
        layer.lineWidth = posePointWidth
        layer.strokeColor = referencePoseStrokeColor
        layer.fillColor = referencePosePointColor
        layer.contentsGravity = .resizeAspectFill
        return layer
    }()
    
    lazy var recordPoseEdgeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.frame = view.bounds
        layer.lineWidth = poseEdgeWidth
        layer.strokeColor = referencePoseStrokeColor
        layer.lineCap = .round
        layer.contentsGravity = .resizeAspectFill
        return layer
    }()
    
    lazy var recordDisplayTimer: Timer = {
        let timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(self.displayRecord), userInfo: nil, repeats: true)
        return timer
    }()
    
    lazy var retakeButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = cornerRadius
        button.backgroundColor = .red
        button.setTitle("취소", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        button.addTarget(self, action: #selector(self.handleRetakeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = cornerRadius
        button.backgroundColor = .systemGreen
        button.setTitle("영상 사용하기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        button.addTarget(self, action: #selector(self.handleConfirmButtonTapped), for: .touchUpInside)
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
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
        self.bindUI()
        self.recordVideo.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.recordVideo.pause()
        self.recordVideo.removeTimeObserver(self.timeObserver!)
        self.timeObserver = nil
        self.recordDisplayTimer.invalidate()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        self.view.layer.addSublayer(self.fakeCaptureLayer)
        self.view.layer.addSublayer(self.recordVideoLayer)
        self.view.layer.addSublayer(self.overlayLayer)
        self.view.addSubview(self.retakeButton)
        self.view.addSubview(self.confirmButton)
        self.view.addSubview(self.progressBar)
        
        self.retakeButton.snp.makeConstraints {
            $0.right.equalTo(self.view.snp.right).offset(-15)
            $0.bottom.equalTo(self.view.snp.bottom).offset(-30)
            $0.height.equalTo(50)
            $0.width.equalTo(100)
        }
        
        self.confirmButton.snp.makeConstraints {
            $0.left.equalTo(self.view.snp.left).offset(15)
            $0.centerY.equalTo(self.retakeButton.snp.centerY)
            $0.right.equalTo(self.retakeButton.snp.left).offset(-15)
            $0.height.equalTo(50)
        }
        
        self.progressBar.snp.makeConstraints {
            $0.top.equalTo(self.view.snp.topMargin)
            $0.left.equalTo(self.view.snp.left).offset(15)
            $0.right.equalTo(self.view.snp.right).offset(-15)
        }
    }
    
    func displayRecordPose(points : [VNHumanBodyPoseObservation.JointName : CGPoint?], edges: [Edge]) {
        // Removes old points and edges
        self.recordPoseEdgePaths.removeAllPoints()
        self.recordPosePointPaths.removeAllPoints()
        
        // Add new edges
        for edge in edges {
            guard let from = points[edge.from]!, let to = points[edge.to]! else { continue }
            let path = UIBezierPath()
            path.move(to: from)
            path.addLine(to: to)
            self.recordPoseEdgePaths.append(path)
        }
        
        // Add new points
        for (_, point) in points {
            guard let point = point else { continue }
            let path = UIBezierPath(center: point, radius: posePointRadius)
            self.recordPosePointPaths.append(path)
        }
        
        // Commit new edges and points
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.recordPoseEdgeLayer.path = self.recordPoseEdgePaths.cgPath
        self.recordPosePointLayer.path = self.recordPosePointPaths.cgPath
        CATransaction.commit()
    }
    
    func bindUI() {
        self.recordVideoLayer.rx.observe(AVPlayerLayer.self, #keyPath(AVPlayerLayer.isReadyForDisplay))
            .subscribe(onNext: { _ in
                self.displayStartTime = Date().toMilliSeconds
                self.recordDisplayTimer.fire()
            })
            .disposed(by: self.disposeBag)
    }
    
    // MARK: - Actions
    
    @objc func handleRetakeButtonTapped() {
        let recordViewController = RecordViewController()
        recordViewController.isHeroEnabled = true
        
        var newViewControllers = self.navigationController?.viewControllers
        newViewControllers?.removeLast()
        newViewControllers?.removeLast()
        newViewControllers?.append(recordViewController)
        self.navigationController?.setViewControllers(newViewControllers!, animated: true)
    }
    
    @objc func handleConfirmButtonTapped() {
        self.navigationController?.popToViewController(ofClass: UploadViewController.self)
    }
    
    @objc func displayRecord() {
        let time = Int(Date().toMilliSeconds - self.displayStartTime)
        if let codablePose = self.viewModel.poseSequence.poses[time] {
            let recordedBody = Pose(from: codablePose)
            recordedBody.buildPoseAndDisplay(for: self.fakeCaptureLayer, on: self.overlayLayer, completion: self.displayRecordPose(points:edges:))
        }
    }
}
