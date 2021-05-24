//
//  Skeleton.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/24.
//

import UIKit
import AVKit
import Vision

class Skeleton {
    var leftAnkle: CGPoint?
    var leftKnee: CGPoint?
    var leftHip: CGPoint?
    var leftShoulder: CGPoint?
    var leftElbow: CGPoint?
    var leftWrist: CGPoint?
    var leftEye: CGPoint?
    var leftEar: CGPoint?
    var rightAnkle: CGPoint?
    var rightKnee: CGPoint?
    var rightHip: CGPoint?
    var rightShoulder: CGPoint?
    var rightElbow: CGPoint?
    var rightWrist: CGPoint?
    var rightEye: CGPoint?
    var rightEar: CGPoint?
    var nose: CGPoint?
    var delegate: SkeletonDelegate
    
    init(observed body: VNHumanBodyPoseObservation, delegate: SkeletonDelegate) {
        self.delegate = delegate
        do {
            self.leftAnkle = try body.recognizedPoint(.leftAnkle).toCGPoint()
            self.leftKnee = try body.recognizedPoint(.leftKnee).toCGPoint()
            self.leftHip = try body.recognizedPoint(.leftHip).toCGPoint()
            self.leftShoulder = try body.recognizedPoint(.leftShoulder).toCGPoint()
            self.leftElbow = try body.recognizedPoint(.leftElbow).toCGPoint()
            self.leftWrist = try body.recognizedPoint(.leftWrist).toCGPoint()
            self.leftEye = try body.recognizedPoint(.leftEye).toCGPoint()
            self.leftEar = try body.recognizedPoint(.leftEar).toCGPoint()
            self.rightAnkle = try body.recognizedPoint(.rightAnkle).toCGPoint()
            self.rightKnee = try body.recognizedPoint(.rightKnee).toCGPoint()
            self.rightHip = try body.recognizedPoint(.rightHip).toCGPoint()
            self.rightShoulder = try body.recognizedPoint(.rightShoulder).toCGPoint()
            self.rightElbow = try body.recognizedPoint(.rightElbow).toCGPoint()
            self.rightWrist = try body.recognizedPoint(.rightWrist).toCGPoint()
            self.rightEye = try body.recognizedPoint(.rightEye).toCGPoint()
            self.rightEar = try body.recognizedPoint(.rightEar).toCGPoint()
            self.nose = try body.recognizedPoint(.nose).toCGPoint()
        } catch {
            print("??")
        }
    }
    
    func showSkeleton(for captureLayer: AVCaptureVideoPreviewLayer, on overlayLayer: CAShapeLayer) {
        var bodyPoints: [CGPoint] = []
        
        bodyPoints.append(captureLayer.layerPointConverted(fromCaptureDevicePoint: self.leftAnkle!))
        bodyPoints.append(captureLayer.layerPointConverted(fromCaptureDevicePoint: self.leftKnee!))
        bodyPoints.append(captureLayer.layerPointConverted(fromCaptureDevicePoint: self.leftHip!))
        bodyPoints.append(captureLayer.layerPointConverted(fromCaptureDevicePoint: self.leftShoulder!))
        bodyPoints.append(captureLayer.layerPointConverted(fromCaptureDevicePoint: self.leftElbow!))
        bodyPoints.append(captureLayer.layerPointConverted(fromCaptureDevicePoint: self.leftWrist!))
        bodyPoints.append(captureLayer.layerPointConverted(fromCaptureDevicePoint: self.leftEye!))
        bodyPoints.append(captureLayer.layerPointConverted(fromCaptureDevicePoint: self.leftEar!))
        bodyPoints.append(captureLayer.layerPointConverted(fromCaptureDevicePoint: self.rightAnkle!))
        bodyPoints.append(captureLayer.layerPointConverted(fromCaptureDevicePoint: self.rightKnee!))
        bodyPoints.append(captureLayer.layerPointConverted(fromCaptureDevicePoint: self.rightHip!))
        bodyPoints.append(captureLayer.layerPointConverted(fromCaptureDevicePoint: self.rightShoulder!))
        bodyPoints.append(captureLayer.layerPointConverted(fromCaptureDevicePoint: self.rightElbow!))
        bodyPoints.append(captureLayer.layerPointConverted(fromCaptureDevicePoint: self.rightWrist!))
        bodyPoints.append(captureLayer.layerPointConverted(fromCaptureDevicePoint: self.rightEye!))
        bodyPoints.append(captureLayer.layerPointConverted(fromCaptureDevicePoint: self.rightEar!))
        
        self.delegate.showBodyPoints(points: bodyPoints)
    }
}

protocol SkeletonDelegate {
    func showBodyPoints(points: [CGPoint])
}
