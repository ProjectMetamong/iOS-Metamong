//
//  ExerciseCamViewController.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/23.
//

import UIKit
import AVKit
import SnapKit
import Vision
import RxSwift
import RxRelay
import RxCocoa

class ExerciseCamViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: ExerciseCamViewModel = ExerciseCamViewModel()
    
    // Capture Session DataOutputQueue
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInteractive)
    
    // User and Reference Pose Related
    private var userPoseEdgePaths = UIBezierPath()
    private var userPosePointPaths = UIBezierPath()
    private var referencePoseEdgePaths = UIBezierPath()
    private var referencePosePointPaths = UIBezierPath()
    private var bodyPoseRequest = VNDetectHumanBodyPoseRequest()
    private var recordedPoseVector: [Float?]? = nil
    
    // Evaluation Time Related
    private var evaluationStartTime: Int64 = Date().toMilliSeconds
    private var lastRecordedPoseTime: Int? = nil
    private var remainingReadyTime: Int = 6
    private var latestCapturedTime: Int64? = nil
    private var isEvaluating: Bool = false
    var timeObserver: Any?
    
    private var disposeBag: DisposeBag = DisposeBag()
    
    lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
    
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return session }
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return session }
        guard session.canAddInput(deviceInput) else { return session }
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        guard session.canAddOutput(dataOutput) else { return session }
        session.addOutput(dataOutput)
        dataOutput.alwaysDiscardsLateVideoFrames = true
        dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
    
        session.commitConfiguration()
        
        return session
    }()
    
    lazy var referenceVideo: AVPlayer = {
        let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileUrl = documentsDirectoryUrl?.appendingPathComponent("test.mov")
        let player = AVPlayer(url: fileUrl!)
        
        self.timeObserver = player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.01, preferredTimescale: 600), queue: DispatchQueue.main) { CMTime in
            if self.referenceVideo.currentItem?.status == .readyToPlay {
                let duration = CMTimeGetSeconds((self.referenceVideo.currentItem?.asset.duration)!)
                let currentTime = CMTimeGetSeconds((self.referenceVideo.currentTime()))
                let progress = Float(currentTime / duration) * 100
                self.progressBar.value = progress
            }
        }
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak self] _ in
            self?.evaluationFinished()
        }

        return player
    }()
    
    lazy var referenceVideoLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer(player: self.referenceVideo)
        layer.isHidden = true
        
        layer.frame = view.bounds
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    lazy var captureLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer()
        layer.frame = view.bounds
        layer.videoGravity = .resizeAspectFill
        layer.session = self.captureSession
        self.captureSession.startRunning()
        return layer
    }()
    
    lazy var overlayLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.frame = view.bounds
        layer.contentsGravity = .resizeAspectFill
        layer.addSublayer(referencePoseEdgeLayer)
        layer.addSublayer(referencePosePointLayer)
        layer.addSublayer(userPoseEdgeLayer)
        layer.addSublayer(userPosePointLayer)
        return layer
    }()
    
    lazy var userPosePointLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.frame = view.bounds
        layer.lineWidth = posePointWidth
        layer.strokeColor = userPoseStrokeColor
        layer.fillColor = userPosePointColor
        layer.contentsGravity = .resizeAspectFill
        return layer
    }()
    
    lazy var userPoseEdgeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.frame = view.bounds
        layer.lineWidth = poseEdgeWidth
        layer.strokeColor = userPoseStrokeColor
        layer.lineCap = .round
        layer.contentsGravity = .resizeAspectFill
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
    
    lazy var referenceDisplayTimer: Timer = {
        let timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(self.displayReference), userInfo: nil, repeats: true)
        return timer
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
    
    var scoreLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.italicSystemFont(ofSize: 120)
        label.textColor = .white
        return label
    }()
    
    lazy var standByLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 150, weight: .heavy)
        label.textColor = .white
        label.text = "5"
        label.isHidden = true
        return label
    }()
    
    lazy var standByBackground: UIView = {
        let view = UIView(frame: CGRect())
        view.clipsToBounds = true
        view.layer.cornerRadius = 100
        view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        view.isHidden = true
        return view
    }()
    
    lazy var standByTimer: Timer = {
        let timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countDown), userInfo: nil, repeats: true)
        return timer
    }()
    
    private lazy var startStandByCountDownTrigger: Void = {
        DispatchQueue.main.async {
            self.standByLabel.isHidden = false
            self.standByBackground.isHidden = false
            self.standByTimer.fire()
        }
    }()
    
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
        self.bindUI()
        self.displayInitialReferencePose()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.captureSession.stopRunning()
        self.referenceVideo.pause()
        self.referenceVideo.removeTimeObserver(self.timeObserver!)
        self.timeObserver = nil
        self.referenceDisplayTimer.invalidate()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        self.view.layer.addSublayer(self.captureLayer)
        self.view.layer.addSublayer(self.referenceVideoLayer)
        self.view.layer.addSublayer(self.overlayLayer)
        self.view.addSubview(self.stopButton)
        self.view.addSubview(self.progressBar)
        self.view.addSubview(self.scoreLabel)
        self.view.addSubview(self.standByLabel)
        self.view.addSubview(self.standByBackground)
        
        self.view.bringSubviewToFront(self.standByLabel)
        
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
        
        self.scoreLabel.snp.makeConstraints {
            $0.bottom.equalTo(self.stopButton.snp.top).offset(-15)
            $0.right.equalTo(self.view.snp.right).offset(-15)
        }
        
        self.standByLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.view.snp.centerY)
            $0.centerX.equalTo(self.view.snp.centerX)
        }
        
        self.standByBackground.snp.makeConstraints {
            $0.centerY.equalTo(self.standByLabel.snp.centerY)
            $0.centerX.equalTo(self.standByLabel.snp.centerX)
            $0.width.equalTo(200)
            $0.height.equalTo(200)
        }
    }
    
    func bindUI() {
        self.viewModel.currentScore
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { score in
                guard let score = score else { return }
                self.scoreLabel.text = "\(score)"
            })
            .disposed(by: self.disposeBag)
    }
    
    func displayUserPose(points : [VNHumanBodyPoseObservation.JointName : CGPoint?], edges: [Edge]) {
        // Removes old points and edges
        self.userPoseEdgePaths.removeAllPoints()
        self.userPosePointPaths.removeAllPoints()
        
        // Add new edges
        for edge in edges {
            guard let from = points[edge.from]!, let to = points[edge.to]! else { continue }
            let path = UIBezierPath()
            path.move(to: from)
            path.addLine(to: to)
            self.userPoseEdgePaths.append(path)
        }
        
        // Add new points
        for (_, point) in points {
            guard let point = point else { continue }
            let path = UIBezierPath(center: point, radius: posePointRadius)
            self.userPosePointPaths.append(path)
        }
        
        // Commit new edges and points
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.userPoseEdgeLayer.path = self.userPoseEdgePaths.cgPath
        self.userPosePointLayer.path = self.userPosePointPaths.cgPath
        CATransaction.commit()
    }
    
    func eraseOldUserPose() {
        // Removes old points and edges
        self.userPoseEdgePaths.removeAllPoints()
        self.userPosePointPaths.removeAllPoints()
        
        // Commit new edges and points
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.userPoseEdgeLayer.path = self.userPoseEdgePaths.cgPath
        self.userPosePointLayer.path = self.userPosePointPaths.cgPath
        CATransaction.commit()
    }
    
    func displayReferencePose(points : [VNHumanBodyPoseObservation.JointName : CGPoint?], edges: [Edge]) {
        // Removes old points and edges
        self.referencePoseEdgePaths.removeAllPoints()
        self.referencePosePointPaths.removeAllPoints()
        
        // Add new edges
        for edge in edges {
            guard let from = points[edge.from]!, let to = points[edge.to]! else { continue }
            let path = UIBezierPath()
            path.move(to: from)
            path.addLine(to: to)
            self.referencePoseEdgePaths.append(path)
        }
        
        // Add new points
        for (_, point) in points {
            guard let point = point else { continue }
            let path = UIBezierPath(center: point, radius: posePointRadius)
            self.referencePosePointPaths.append(path)
        }
        
        // Commit new edges and points
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.referencePoseEdgeLayer.path = self.referencePoseEdgePaths.cgPath
        self.referencePosePointLayer.path = self.referencePosePointPaths.cgPath
        CATransaction.commit()
    }
    
    func eraseOldReferencePose() {
        // Removes old points and edges
        self.referencePoseEdgePaths.removeAllPoints()
        self.referencePosePointPaths.removeAllPoints()
        
        // Commit new edges and points
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.referencePoseEdgeLayer.path = self.referencePoseEdgePaths.cgPath
        self.referencePosePointLayer.path = self.referencePosePointPaths.cgPath
        CATransaction.commit()
    }
    
    func displayScore(similarity: Float) {
        self.viewModel.appendScore(similarity: similarity)
    }
    
    func displayInitialReferencePose() {
        guard let codablePose = self.viewModel.poseSequence.poses[self.viewModel.poseSequence.initialPoseTime] else { return }
        let initialBody = Pose(from: codablePose)
        initialBody.buildPoseAndDisplay(for: self.captureLayer, on: self.overlayLayer, completion: self.displayReferencePose(points:edges:))
    }
    
    func evaluationFinished() {
        let resultViewController = ResultViewController()
        resultViewController.viewModel = ResultViewModel(score: self.viewModel.averageScore)
        self.navigationController?.pushViewController(resultViewController, animated: true)
    }
    
    // MARK: - Actions
    
    @objc func handleStopButtonTapped() {
        self.navigationController?.popToViewController(ofClass: DetailViewController.self)
    }
    
    @objc func displayReference() {
        let currentTime = Int(Date().toMilliSeconds - self.evaluationStartTime)
        if let codablePose = self.viewModel.poseSequence.poses[currentTime] {
            self.lastRecordedPoseTime = currentTime
            let recordedBody = Pose(from: codablePose)
            self.recordedPoseVector = recordedBody.buildPoseVector()
            recordedBody.buildPoseAndDisplay(for: self.captureLayer, on: self.overlayLayer, completion: self.displayReferencePose(points:edges:))
        } else {
            guard let lastRecrodedPoseTime = self.lastRecordedPoseTime else { return }
            if lastRecrodedPoseTime < currentTime - 1000 {
                self.eraseOldReferencePose()
                self.recordedPoseVector = nil
            }
        }
    }
    
    @objc func countDown() {
        if self.remainingReadyTime > 0 {
            self.remainingReadyTime -= 1
            self.standByLabel.text = "\(self.remainingReadyTime)"
        } else if self.remainingReadyTime == 0 {
            self.standByBackground.isHidden = true
            self.standByLabel.isHidden = true
            self.evaluationStartTime = Date().toMilliSeconds
            self.latestCapturedTime = self.evaluationStartTime
            self.referenceDisplayTimer.fire()
            self.standByTimer.invalidate()
            self.isEvaluating = true
            self.referenceVideo.play()
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension ExerciseCamViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Clear old pose or stop recording based on latest pose captured dtime
        if let latestCapturedTime = self.latestCapturedTime {
            let currentTime = Date().toMilliSeconds
            if latestCapturedTime < currentTime - 3000 {
                DispatchQueue.main.sync {
                    self.navigationController?.popToViewController(ofClass: DetailViewController.self)
                }
            } else if latestCapturedTime < currentTime - 1000 {
                self.eraseOldUserPose()
            }
        }
        
        // User body pose estimation
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        try? handler.perform([bodyPoseRequest])
        
        guard let observation = bodyPoseRequest.results?.first else { return }
        let observedBody = Pose(observed: observation, another: self.recordedPoseVector, completion: self.displayScore(similarity:))
        _ = startStandByCountDownTrigger
        
        // Display user body pose
        DispatchQueue.main.sync {
            observedBody.buildPoseAndDisplay(for: self.captureLayer, on: self.overlayLayer, completion: self.displayUserPose(points:edges:))
        }
        
        if self.isEvaluating {
            self.latestCapturedTime = Date().toMilliSeconds
        }
    }
}
