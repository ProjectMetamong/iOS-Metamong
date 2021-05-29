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
    var points: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]

    init(observed body: VNHumanBodyPoseObservation) {
        for jointName in jointNames {
            do {
                self.points[jointName] = try body.recognizedPoint(jointName).toCGPoint(threshold: 0.3)
            } catch {
                continue
            }
        }
    }
    
    init(from codablePose: CodablePose) {
        for (jointNameRawValue, point) in codablePose.points {
            self.points[VNHumanBodyPoseObservation.JointName.init(rawValue: VNRecognizedPointKey(rawValue: jointNameRawValue))] = point
        }
    }
    
    func buildPoseAndDisplay(for captureLayer: AVCaptureVideoPreviewLayer, on overlayLayer: CAShapeLayer, completion displayPose: (([VNHumanBodyPoseObservation.JointName : CGPoint?], [Edge]) -> Void)) {
        var pointsForDisplay: [VNHumanBodyPoseObservation.JointName: CGPoint?] = [:]
        var edgesForDisplay: [Edge] = []
        
        for (key, point) in self.points {
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

struct CodablePose: Codable {
    var points: [String: CGPoint] = [:]
    
    init(from pose: Pose) {
        for joint in jointNames {
            let point = pose.points[joint]
            points[joint.rawValue.rawValue] = point
        }
    }
}

struct PoseSequence: Codable {
    var initialPoseTime: Int
    var poses: [Int: CodablePose]
    
    init() {
        self.initialPoseTime = -1
        self.poses = [:]
    }
    
    init(from name: String) {
        self.initialPoseTime = -1
        self.poses = [:]
        
        guard let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileUrl = documentsDirectoryUrl.appendingPathComponent("\(name).json")

        do {
            let data = try Data(contentsOf: fileUrl, options: [])
            let decoder = JSONDecoder()
            let jsonData = try? decoder.decode(PoseSequence.self, from: data)
            guard let decoded = jsonData else { return }
            self.initialPoseTime = decoded.initialPoseTime
            self.poses = decoded.poses
        } catch {
            print(error)
        }
    }
    
    func encodeAndSave(as name: String, completion: @escaping(() -> Void)) {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(self) {
            guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            let fileUrl = documentDirectoryUrl.appendingPathComponent("\(name).json")
            
            do {
                try jsonData.write(to: fileUrl, options: [])
                completion()
            } catch {
                print(error)
            }
        }
    }
}
