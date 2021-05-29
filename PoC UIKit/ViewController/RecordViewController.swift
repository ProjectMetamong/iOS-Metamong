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
    
    private var viewModel: RecordViewModel = RecordViewModel()
    
    // Capture Session DataOutputQueues
    private let videoDataOutputQueue = DispatchQueue(label: "CameraDataOutput", qos: .userInteractive)
    private let audioDataOutputQueue = DispatchQueue(label: "AudioDataOutput", qos: .userInteractive)
    
    // User Pose Related
    private var userPoseEdgePaths = UIBezierPath()
    private var userPosePointPaths = UIBezierPath()
    private var bodyPoseRequest = VNDetectHumanBodyPoseRequest()
    
    // Recording Time Related
    private var recordingStartTime: Int64 = Date().toMilliSeconds
    private var remainingReadyTime: Int = 6
    private var isRecording: Bool = false
    
    // Video/Audio File Related
    private var videoWidth = 0
    private var videoHeight = 0
    private var audioVideoWriter: AVWriter? = nil
    
    lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
    
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return session }
        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else { return session }
        guard session.canAddInput(videoInput) else { return session }
        session.addInput(videoInput)
        
        let dimension = CMVideoFormatDescriptionGetDimensions(videoDevice.activeFormat.formatDescription)
        self.videoWidth = Int(dimension.width)
        self.videoHeight = Int(dimension.height)
        
        guard let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio) else { return session }
        guard let audioInput = try? AVCaptureDeviceInput(device: audioDevice) else { return session }
        guard session.canAddInput(audioInput) else { return session }
        session.addInput(audioInput)
        
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.connection(with: AVMediaType.video)?.videoOrientation = .portrait
        videoDataOutput.connection(with: AVMediaType.video)?.isVideoMirrored = true
        
        guard session.canAddOutput(videoDataOutput) else { return session }
        session.addOutput(videoDataOutput)
        
        let audioDataOutput = AVCaptureAudioDataOutput()
        guard session.canAddOutput(audioDataOutput) else { return session }
        session.addOutput(audioDataOutput)
        
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        audioDataOutput.setSampleBufferDelegate(self, queue: audioDataOutputQueue)
        
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
    
    lazy var stopButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = cornerRadius
        button.backgroundColor = UIColor(cgColor: recordIndicatingColor)
        button.setTitle("촬영 종료", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .heavy)
        button.addTarget(self, action: #selector(self.handleStopButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var recordingTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .bold)
        label.layer.cornerRadius = 3
        label.layer.masksToBounds = true
        label.textColor = .white
        label.text = 0.msToTimeString(forStopWatch: true)
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        self.view.addSubview(self.standByLabel)
        self.view.addSubview(self.standByBackground)
        self.view.addSubview(self.recordingTimeLabel)
        
        self.view.bringSubviewToFront(self.standByLabel)
        
        self.stopButton.snp.makeConstraints {
            $0.left.equalTo(self.view.snp.left).offset(15)
            $0.right.equalTo(self.view.snp.right).offset(-15)
            $0.bottom.equalTo(self.view.snp.bottom).offset(-30)
            $0.height.equalTo(50)
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
        
        self.recordingTimeLabel.snp.makeConstraints {
            $0.centerX.equalTo(self.view.snp.centerX)
            $0.top.equalTo(self.view.snp.topMargin)
        }
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

    func animateRecordingTimeLabel() {
        UIView.animate(withDuration: 0.2, animations: {
            self.recordingTimeLabel.layer.backgroundColor = recordIndicatingColor
        })
    }
    
    // MARK: - Actions
    
    @objc func handleStopButtonTapped() {
        if self.isRecording {
            self.captureSession.stopRunning()
            self.audioVideoWriter?.stop(completion: {
                self.viewModel.poseSequence.encodeAndSave(as: "test") {
                    DispatchQueue.main.sync {
                        let recordConfirmViewController = RecordConfirmViewController()
                        recordConfirmViewController.isHeroEnabled = true
                        self.navigationController?.pushViewController(recordConfirmViewController, animated: true)
                    }
                }
            })
        } else {
            self.navigationController?.popToViewController(ofClass: UploadViewController.self)
        }
    }
    
    @objc func countDown() {
        if self.remainingReadyTime > 0 {
            self.remainingReadyTime -= 1
            self.standByLabel.text = "\(self.remainingReadyTime)"
        } else if self.remainingReadyTime == 0 {
            self.standByBackground.isHidden = true
            self.standByLabel.isHidden = true
            self.standByTimer.invalidate()
            self.recordingStartTime = Date().toMilliSeconds
            self.animateRecordingTimeLabel()
            self.isRecording = true
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate & AVCaptureAudioDataOutputSampleBufferDelegate

extension RecordViewController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Video/Audio recording
        
        if isRecording {
            let isVideoData = output is AVCaptureVideoDataOutput
            if self.audioVideoWriter == nil && !isVideoData{
                guard let fmt = CMSampleBufferGetFormatDescription(sampleBuffer) else { return }
                guard let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(fmt) else { return }
                let channels = Int(asbd.pointee.mChannelsPerFrame)
                let samples = asbd.pointee.mSampleRate
                self.audioVideoWriter = AVWriter(height: self.videoHeight, width: self.videoWidth, channels: channels, samples: samples, saveAs: "test")
                self.audioVideoWriter?.delegate = self
            }
            audioVideoWriter?.write(sampleBuffer: sampleBuffer, isVideoData: isVideoData)
        }
        
        // User body pose estimation
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        try? handler.perform([bodyPoseRequest])
        
        guard let observation = bodyPoseRequest.results?.first else { return }
        _ = startStandByCountDownTrigger
        let observedBody = Pose(observed: observation)
        
        // Display user body pose
        DispatchQueue.main.sync {
            observedBody.buildPoseAndDisplay(for: self.captureLayer, on: self.overlayLayer, completion: self.displayUserPose(points:edges:))
        }
    
        // User body pose recording
        if self.isRecording {
            let currentTime = Int(Date().toMilliSeconds - self.recordingStartTime)
            if self.viewModel.poseSequence.initialPoseTime == -1 {
                self.viewModel.poseSequence.initialPoseTime = currentTime
            }
            self.viewModel.poseSequence.poses[currentTime] = CodablePose(from: observedBody)
        }
    }
}

// MARK: - AVWriterDelegate

extension RecordViewController: AVWriterDelegate {
    func updateRecordingTime(ms: Int) {
        DispatchQueue.main.sync {
            self.recordingTimeLabel.text = ms.msToTimeString(forStopWatch: true)
        }
    }
}
