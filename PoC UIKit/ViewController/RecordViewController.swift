//
//  RecordViewController.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/26.
//

import UIKit
import AVKit
import SnapKit
import Vision

class RecordViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: RecordViewModel = RecordViewModel()
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInteractive)
    
    private var userPoseEdgePaths = UIBezierPath()
    private var userPosePointPaths = UIBezierPath()
    private var bodyPoseRequest = VNDetectHumanBodyPoseRequest()
    
    private var startingTime: Int64?
    private var remainingReadyTime: Int = 6
    private var isRecording: Bool = false
    
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
        layer.addSublayer(userPoseEdgeLayer)
        layer.addSublayer(userPosePointLayer)
        return layer
    }()
    
    lazy var userPosePointLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.frame = view.bounds
        layer.fillColor = #colorLiteral(red: 0, green: 0.9810667634, blue: 0.5736914277, alpha: 1)
        layer.contentsGravity = .resizeAspectFill
        return layer
    }()
    
    lazy var userPoseEdgeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.frame = view.bounds
        layer.lineWidth = 3
        layer.strokeColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        layer.lineCap = .round
        layer.contentsGravity = .resizeAspectFill
        return layer
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
    
    lazy var stopButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = cornerRadius
        button.backgroundColor = .red
        button.setTitle("촬영 종료", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        button.addTarget(self, action: #selector(self.handleStopButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - Helpers
    
    func configureUI() {
        self.view.layer.addSublayer(captureLayer)
        self.view.layer.addSublayer(overlayLayer)
        self.view.addSubview(self.stopButton)
        self.view.addSubview(self.countDownLabel)
        self.view.addSubview(self.countDownBackgroundView)
        
        self.view.bringSubviewToFront(self.countDownLabel)
        
        self.stopButton.snp.makeConstraints {
            $0.left.equalTo(self.view.snp.left).offset(15)
            $0.right.equalTo(self.view.snp.right).offset(-15)
            $0.bottom.equalTo(self.view.snp.bottom).offset(-30)
            $0.height.equalTo(50)
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
            let path = UIBezierPath(ovalIn: CGRect(x: point.x - 3, y: point.y - 3, width: 6, height: 6))
            self.userPosePointPaths.append(path)
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.userPoseEdgeLayer.path = self.userPoseEdgePaths.cgPath
        self.userPosePointLayer.path = self.userPosePointPaths.cgPath
        CATransaction.commit()
    }
    
    // MARK: - Actions
    
    @objc func handleStopButtonTapped() {
        self.viewModel.poseSequence.encodeAndSave(as: "test")
        self.navigationController?.popToViewController(ofClass: UploadViewController.self)
    }
    
    @objc func countDown() {
        if self.remainingReadyTime > 0 {
            self.remainingReadyTime -= 1
            self.countDownLabel.text = "\(self.remainingReadyTime)"
        } else if self.remainingReadyTime == 0 {
            self.countDownBackgroundView.isHidden = true
            self.countDownLabel.isHidden = true
            self.startingTime = Date().toMilliSeconds
            self.isRecording = true
            self.countDownTimer.invalidate()
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension RecordViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([bodyPoseRequest])
            guard let observation = bodyPoseRequest.results?.first else {
                return
            }
            let observedBody = Pose(observed: observation)
            DispatchQueue.main.sync {
                if self.isRecording {
                    let time = Int(Date().toMilliSeconds - self.startingTime!)
                    print(time)
                    if self.viewModel.poseSequence.initialPoseTime == -1 {
                        self.viewModel.poseSequence.initialPoseTime = time
                    }
                    self.viewModel.poseSequence.poses[time] = CodablePose(from: observedBody)
                }
                observedBody.buildPoseAndDisplay(for: self.captureLayer, on: self.overlayLayer, completion: self.displayUserPose(points:edges:))
            }
            return
        } catch {
            captureSession.stopRunning()
            return
        }
    }
}
