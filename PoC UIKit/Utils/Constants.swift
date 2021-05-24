//
//  Constants.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/17.
//

import UIKit
import Nuke
import Vision

let backgroundColor = UIColor(red: 252 / 255, green: 247 / 255, blue: 227 / 255, alpha: 1.0)
let buttonColor = UIColor(red: 250 / 255, green: 136 / 255, blue: 136 / 255, alpha: 1.0)

let cornerRadius = CGFloat(20)

let nukeOptions = ImageLoadingOptions(
    transition: .fadeIn(duration: 0.45)
)

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
