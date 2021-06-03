//
//  ExerciseReferenceViewModel.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/27.
//

import Foundation

class ExerciseReferenceViewModel {
    var exerciseId: Int?
    var poseSequence: PoseSequence?
    
    init(id: Int) {
        self.exerciseId = id
        self.poseSequence = PoseSequence(from: "\(id)")
    }
}
