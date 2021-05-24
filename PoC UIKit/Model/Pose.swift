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

    init(observed body: VNHumanBodyPoseObservation) {
        for jointName in jointNames {
            self.points[jointName] = try? body.recognizedPoint(jointName).toCGPoint(threshold: 0.3)
        }
    }

    func buildPoseAndDisplay(for captureLayer: AVCaptureVideoPreviewLayer, on overlayLayer: CAShapeLayer, completion displayPose: (([VNHumanBodyPoseObservation.JointName : CGPoint?], [Edge]) -> Void)) {
        var pointsForDisplay: [VNHumanBodyPoseObservation.JointName: CGPoint?] = [:]
        var edgesForDisplay: [Edge] = []
        
        for (key, point) in self.points {
            guard let point = point else { continue }
            let actualPoint = captureLayer.layerPointConverted(fromCaptureDevicePoint: point)
            pointsForDisplay[key] = actualPoint
        }
        
        for edge in edges {
            guard let _ = pointsForDisplay[edge.from], let _ = pointsForDisplay[edge.to] else { continue }
            edgesForDisplay.append(edge)
        }

        displayPose(pointsForDisplay, edgesForDisplay)
    }
}
