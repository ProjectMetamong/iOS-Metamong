//
//  Pose.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/24.
//

import UIKit
import AVKit
import Vision

struct Edge {
    let from: VNHumanBodyPoseObservation.JointName
    let to: VNHumanBodyPoseObservation.JointName
}

struct Pose {
    var points: [VNHumanBodyPoseObservation.JointName: CGPoint?] = [:]
    var delegate: PoseDelegate
    
    static let edges = [
        Edge(from: .nose, to: .leftEye),
        Edge(from: .leftEye, to: .leftEar),
        Edge(from: .nose, to: .rightEye),
        Edge(from: .rightEye, to: .rightEar),
        Edge(from: .nose, to: .leftShoulder),
        Edge(from: .leftShoulder, to: .leftElbow),
        Edge(from: .leftElbow, to: .leftWrist),
        Edge(from: .leftShoulder, to: .leftHip),
        Edge(from: .leftHip, to: .leftKnee),
        Edge(from: .leftKnee, to: .leftAnkle),
        Edge(from: .nose, to: .rightShoulder),
        Edge(from: .rightShoulder, to: .rightElbow),
        Edge(from: .rightElbow, to: .rightWrist),
        Edge(from: .rightShoulder, to: .rightHip),
        Edge(from: .rightHip, to: .rightKnee),
        Edge(from: .rightKnee, to: .rightAnkle)
    ]

    init(observed body: VNHumanBodyPoseObservation, delegate: PoseDelegate) {
        self.delegate = delegate
        for jointName in jointNames {
            self.points[jointName] = try? body.recognizedPoint(jointName).toCGPoint(threshold: 0.3)
        }
    }

    func buildPoseForDisplay(for captureLayer: AVCaptureVideoPreviewLayer, on overlayLayer: CAShapeLayer) {
        var pointsForDisplay: [VNHumanBodyPoseObservation.JointName: CGPoint?] = [:]
        var edgesForDisplay: [Edge] = []
        
        for (key, point) in self.points {
            guard let point = point else { continue }
            let actualPoint = captureLayer.layerPointConverted(fromCaptureDevicePoint: point)
            pointsForDisplay[key] = actualPoint
        }
        
        for edge in Pose.edges {
            guard let _ = pointsForDisplay[edge.from], let _ = pointsForDisplay[edge.to] else { continue }
            edgesForDisplay.append(edge)
        }

        self.delegate.showBodyPoints(points: pointsForDisplay, edges: edgesForDisplay)
    }
}

protocol PoseDelegate {
    func showBodyPoints(points: [VNHumanBodyPoseObservation.JointName: CGPoint?], edges: [Edge])
}
