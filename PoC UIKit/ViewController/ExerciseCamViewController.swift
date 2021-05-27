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

class ExerciseCamViewController: UIViewController {
    
    // MARK: - Debug variables

    private var previousTime: Int64?
    private var intervals: [Int] = []
    
    // MARK: - Properties
    
    private let viewModel: ExerciseCamViewModel = ExerciseCamViewModel()
    
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInteractive)
    
    private var userPoseEdgePaths = UIBezierPath()
    private var userPosePointPaths = UIBezierPath()
    private var referencePoseEdgePaths = UIBezierPath()
    private var referencePosePointPaths = UIBezierPath()
    
    private var bodyPoseRequest = VNDetectHumanBodyPoseRequest()
    
    private var startingTime: Int64?
    private var remainingReadyTime: Int = 6
    private var isPlaying: Bool = false {
        didSet {
            self.referenceDisplayTimer.fire()
        }
    }
    
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
    
    lazy var countDownLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 150, weight: .heavy)
        label.textColor = .white
        label.text = "5"
        return label
    }()
    
    lazy var countDownBackgroundView: UIView = {
        let view = UIView(frame: CGRect())
        view.clipsToBounds = true
        view.layer.cornerRadius = 100
        view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        return view
    }()
    
    lazy var countDownTimer: Timer = {
        let timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countDown), userInfo: nil, repeats: true)
        return timer
    }()
    
    lazy var captureLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer()
        layer.frame = view.bounds
        layer.videoGravity = .resizeAspectFill
        layer.session = self.captureSession
        self.captureSession.startRunning()
        self.startingTime = Date().toMilliSeconds
        self.previousTime = startingTime
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
        label.font = UIFont.italicSystemFont(ofSize: 60)
        label.textColor = .white
        return label
    }()
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.referenceDisplayTimer.invalidate()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        self.view.layer.addSublayer(self.captureLayer)
        self.view.layer.addSublayer(self.overlayLayer)
        self.view.addSubview(self.stopButton)
        self.view.addSubview(self.progressBar)
        self.view.addSubview(self.scoreLabel)
        self.view.addSubview(self.countDownLabel)
        self.view.addSubview(self.countDownBackgroundView)
        
        self.view.bringSubviewToFront(self.countDownLabel)
        
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
        
        self.countDownLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.view.snp.centerY)
            $0.centerX.equalTo(self.view.snp.centerX)
        }
        
        self.countDownBackgroundView.snp.makeConstraints {
            $0.centerY.equalTo(self.countDownLabel.snp.centerY)
            $0.centerX.equalTo(self.countDownLabel.snp.centerX)
            $0.width.equalTo(200)
            $0.height.equalTo(200)
        }
        
        self.countDownTimer.fire()
        self.displayInitialReferencePose()
    }
    
    func displayUserPose(points : [VNHumanBodyPoseObservation.JointName : CGPoint?], edges: [Edge]) {
        self.userPoseEdgePaths.removeAllPoints()
        self.userPosePointPaths.removeAllPoints()
        
        for edge in edges {
            guard let from = points[edge.from]!, let to = points[edge.to]! else { continue }
            let path = UIBezierPath()
            path.move(to: from)
            path.addLine(to: to)
            self.userPoseEdgePaths.append(path)
        }
        
        for (key, point) in points {
            guard let point = point else { continue }
            print("key : \(key.rawValue), x : \(point.x), y : \(point.y)")
            let path = UIBezierPath(center: point, radius: posePointRadius)
            self.userPosePointPaths.append(path)
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.userPoseEdgeLayer.path = self.userPoseEdgePaths.cgPath
        self.userPosePointLayer.path = self.userPosePointPaths.cgPath
        CATransaction.commit()
        
        // debug 출력
        let currentTime = Date().toMilliSeconds
        let intervalTime = Int(currentTime - self.previousTime!)
        self.intervals.append(intervalTime)
        let averageInterval = intervals.reduce(0, +) / intervals.count
        previousTime = currentTime
        print("=======================================================================================================")
        print("time : \(currentTime - self.startingTime!), interval : \(intervalTime), average interval : \(averageInterval), total poses : \(intervals.count),  detected points : \(points.count)")
        print("=======================================================================================================")
        self.previousTime = currentTime
    }
    
    func displayInitialReferencePose() {
        guard let codablePose = self.viewModel.poseSequence.poses[self.viewModel.poseSequence.initialPoseTime] else { return }
        let initialBody = Pose(from: codablePose)
        initialBody.buildPoseAndDisplay(for: self.captureLayer, on: self.overlayLayer, completion: self.displayReferencePose(points:edges:))
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
    
    @objc func handleStopButtonTapped() {
        self.navigationController?.popToViewController(ofClass: DetailViewController.self)
    }
    
    @objc func displayReference() {
        let time = Int(Date().toMilliSeconds - self.startingTime!)
        if let codablePose = self.viewModel.poseSequence.poses[time] {
            let recordedBody = Pose(from: codablePose)
            recordedBody.buildPoseAndDisplay(for: self.captureLayer, on: self.overlayLayer, completion: self.displayReferencePose(points:edges:))
        }
    }
    
    @objc func countDown() {
        if self.remainingReadyTime > 0 {
            self.remainingReadyTime -= 1
            self.countDownLabel.text = "\(self.remainingReadyTime)"
        } else if self.remainingReadyTime == 0 {
            self.countDownBackgroundView.isHidden = true
            self.countDownLabel.isHidden = true
            self.startingTime = Date().toMilliSeconds
            self.isPlaying = true
            self.countDownTimer.invalidate()
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension ExerciseCamViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([bodyPoseRequest])
            guard let observation = bodyPoseRequest.results?.first else { return }
            let observedBody = Pose(observed: observation)
            DispatchQueue.main.sync {
                observedBody.buildPoseAndDisplay(for: self.captureLayer, on: self.overlayLayer, completion: self.displayUserPose(points:edges:))
            }
            return
        } catch {
            captureSession.stopRunning()
            return
        }
    }
}
