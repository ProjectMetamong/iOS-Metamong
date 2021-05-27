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
    private let videoDataOutputQueue = DispatchQueue(label: "CameraDataOutput", qos: .userInteractive)
    private let audioDataOutputQueue = DispatchQueue(label: "AudioDataOutput", qos: .userInteractive)
    
    private var userPoseEdgePaths = UIBezierPath()
    private var userPosePointPaths = UIBezierPath()
    private var bodyPoseRequest = VNDetectHumanBodyPoseRequest()
    
    private var startingTime: Int64?
    private var remainingReadyTime: Int = 6
    private var isRecording: Bool = false
    
    var videoWidth = 0
    var videoHeight = 0
    
    private var videoWriter: VideoWriter? = nil
    fileprivate var recordingTime:Int64 = 0
    
    lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        
        self.videoWidth = Int(self.view.frame.height)
        self.videoHeight = Int(self.view.frame.width)
    
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
            let path = UIBezierPath(center: point, radius: posePointRadius)
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
        self.captureSession.stopRunning()
        self.videoWriter?.stop()
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

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate & AVCaptureAudioDataOutputSampleBufferDelegate

extension RecordViewController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([bodyPoseRequest])
            if let observation = bodyPoseRequest.results?.first {
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
            }
        } catch {
            print("Pose not detected!")
        }
        
        if isRecording {
            let isVideo = output is AVCaptureVideoDataOutput
            if self.videoWriter == nil {
                if !isVideo {
                    if let fmt = CMSampleBufferGetFormatDescription(sampleBuffer) {
                        if let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(fmt) {
                            let channels = Int(asbd.pointee.mChannelsPerFrame)
                            let samples = asbd.pointee.mSampleRate
                            self.videoWriter = VideoWriter(height: self.videoHeight, width: self.videoWidth, channels: channels, samples: samples, recordingTime: recordingTime)
                            self.videoWriter?.delegate = self
                        }
                    }
                }
            }

            if videoWriter != nil {
                videoWriter?.write(sampleBuffer: sampleBuffer, isVideo: isVideo)
            }
        }
    }
}

extension RecordViewController : VideoWriterDelegate {
    func changeRecordingTime(s: Int64) {
        print("changeRecordingTime called")
    }
    
    func finishRecording(fileUrl: URL) {
        print("finishRecording called")
    }
}
