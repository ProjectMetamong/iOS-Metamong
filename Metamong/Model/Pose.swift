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

    init(observed body: VNHumanBodyPoseObservation, another recordedPoseVector: [Float?]? = nil, completion displayScore: ((Float) -> Void)? = nil) {
        for jointName in jointNames {
            do {
                self.points[jointName] = try body.recognizedPoint(jointName).toCGPoint(threshold: 0.3)
            } catch {
                continue
            }
        }
        
        guard let recordedPoseVector = recordedPoseVector, let displayScore = displayScore else { return }
        let poseVector = self.buildPoseVector()
        let confidenceVector = self.buildConfidenceVector(with: body)
        
        let sumOfConfidences = confidenceVector.map({$0 ?? 0.0}).reduce(0.0, +)
        
        let sumOfConfidenceWeightedDifferences = zip(poseVector, recordedPoseVector)
            .map { (captured, recorded) -> Float in
                guard let captured = captured, let recorded = recorded else { return 0.0 }
                return abs(captured - recorded)
            }.enumerated().map { (index, value) -> Float in
                let confidenceIndex = Int(index / 2)
                guard let confidence = confidenceVector[confidenceIndex] else { return 0.0 }
                return confidence * value
            }.reduce(0.0) { result, nextValue in
                result + nextValue
            }
        
        let similarity = 1 - ((1 / sumOfConfidences) * sumOfConfidenceWeightedDifferences)
        displayScore(similarity)
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
    
    func buildConfidenceVector(with observedBody: VNHumanBodyPoseObservation) -> [Float?] {
        var confidenceVector: [Float?] = []
        
        // appending confidences of each joint to poseVector
        for eachJoint in jointNames {
            let confidence = try? observedBody.recognizedPoint(eachJoint).confidence
            confidenceVector.append(confidence)
        }
        
        // return confidenceVector with 17 confidences
        return confidenceVector
    }
    
    func buildPoseVector() -> [Float?] {
        var minX: Float = 1000
        var minY: Float = 1000
        var maxX: Float = 0
        var maxY: Float = 0
        
        var poseVector: [Float?] = []
        
        // appending x, y coordinates of each joint to poseVector and calculate the bound of pose
        for eachJoint in jointNames {
            guard let point = self.points[eachJoint] else {
                poseVector.append(nil)
                poseVector.append(nil)
                continue
            }
            let xPosition = Float(point.x)
            let yPosition = Float(point.y)
            
            poseVector.append(xPosition)
            poseVector.append(yPosition)

            minX = xPosition < minX ? xPosition : minX
            minY = yPosition < minY ? yPosition : minY
            maxX = xPosition > maxX ? xPosition : maxX
            maxY = yPosition > maxY ? yPosition : maxY
        }
        
        // resize and scale
        poseVector = poseVector.enumerated().map({ (index, value) -> Float? in
            guard let value = value else { return value }
            return (value - (index % 2 == 0 ? minX : minY)) / (index % 2 == 0 ? (maxX - minX) : (maxY - minY))
        })
        
        // calculate L2 Norm of poseVector
        let l2Norm: Float = sqrt(poseVector.reduce(0.0) { result, newValue in
            guard let value = newValue else { return result }
            return result + (value * value)
        })
        
        // normalize poseVector using L2 Norm
        poseVector = poseVector.map { value -> Float? in
            guard let value = value else { return value }
            return value / l2Norm
        }
        
        // return poseVector with 34 coordinates
        return poseVector
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
