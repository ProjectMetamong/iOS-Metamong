//
//  ExerciseCamViewModel.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/26.
//

import RxSwift
import RxRelay

class ExerciseCamViewModel {
    var scores: [Int] = []
    var scoresPointerFrom: Int = 0
    var scoresPointerTo: Int = 0
    let currentScore = BehaviorRelay<Int?>(value: nil)
    var exerciseId: Int?
    var poseSequence: PoseSequence?
    
    init(id: Int) {
        self.exerciseId = id
        self.poseSequence = PoseSequence(from: "\(id)")
    }
    var currentAverageScoreWindowSize: Int {
        self.scoresPointerTo - self.scoresPointerFrom
    }
    
    var averageScore: Int {
        return Int(self.scores.reduce(0, +) / self.scores.count)
    }
    
    func appendScore(similarity: Float) {
        var score: Int = 0
        if similarity < 0.9 {
            score = Int((similarity / 0.9) * 30)
        } else if similarity < 0.95 {
            score = Int(30 + ((similarity - 0.9) / 5) * 7000)
        } else {
            score = 100
        }
        
        self.scores.append(score)
        self.scoresPointerTo += 1
        self.scoresPointerFrom += self.scoresPointerTo > averageScoreWindowSize ? 1 : 0
        self.currentScore.accept(Int(self.scores.suffix(self.currentAverageScoreWindowSize).reduce(0, +) / self.currentAverageScoreWindowSize))
    }
}
