//
//  Constants.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/17.
//

import UIKit
import Nuke
import Vision
import AWSS3

// MARK: - UI Related

let backgroundColor = CGColor(red: 252 / 255, green: 247 / 255, blue: 227 / 255, alpha: 1.0)
let buttonColor = CGColor(red: 250 / 255, green: 136 / 255, blue: 136 / 255, alpha: 1.0)
let recordIndicatingColor = CGColor(red: 248 / 255, green: 35 / 255, blue: 37 / 255, alpha: 1.0)
let labelBackgroundColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.5)

let cornerRadius = CGFloat(20)

// MARK: - Nuke Settings

let nukeOptions = ImageLoadingOptions(
    transition: .fadeIn(duration: 0.45)
)

// MARK: - Pose Related

let jointNames: [VNHumanBodyPoseObservation.JointName] = [.leftAnkle,
                                                          .leftKnee,
                                                          .leftHip,
                                                          .leftShoulder,
                                                          .leftElbow,
                                                          .leftWrist,
                                                          .leftEye,
                                                          .leftEar,
                                                          .rightAnkle,
                                                          .rightKnee,
                                                          .rightHip,
                                                          .rightShoulder,
                                                          .rightElbow,
                                                          .rightWrist,
                                                          .rightEye,
                                                          .rightEar,
                                                          .nose]

let edges = [Edge(from: .nose, to: .leftEye),
             Edge(from: .leftEye, to: .leftEar),
             Edge(from: .nose, to: .rightEye),
             Edge(from: .rightEye, to: .rightEar),
             Edge(from: .leftShoulder, to: .rightShoulder),
             Edge(from: .leftShoulder, to: .leftElbow),
             Edge(from: .leftElbow, to: .leftWrist),
             Edge(from: .leftShoulder, to: .leftHip),
             Edge(from: .leftHip, to: .leftKnee),
             Edge(from: .leftHip, to: .rightHip),
             Edge(from: .leftKnee, to: .leftAnkle),
             Edge(from: .rightShoulder, to: .rightElbow),
             Edge(from: .rightElbow, to: .rightWrist),
             Edge(from: .rightShoulder, to: .rightHip),
             Edge(from: .rightHip, to: .rightKnee),
             Edge(from: .rightKnee, to: .rightAnkle)]

let posePointRadius: CGFloat = 5
let posePointWidth: CGFloat = 3
let poseEdgeWidth: CGFloat = 5

let userPoseStrokeColor: CGColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
let userPosePointColor: CGColor = #colorLiteral(red: 0, green: 0.9810667634, blue: 0.5736914277, alpha: 1)
let referencePoseStrokeColor: CGColor = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)
let referencePosePointColor: CGColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)

// MARK: - Exercise Related

let difficulties = ["초급", "중급", "고급"]

// MARK: - Evaluation Related

let averageScoreWindowSize = 100

// MARK: - AWSS3 Related

let AWSS3Region = AWSRegionType.APNortheast2
let AWSS3PoolId = ""
let AWSS3BucketName = ""

// MARK: - API Related

let APIPostUrl = ""
