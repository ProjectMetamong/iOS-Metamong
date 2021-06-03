//
//  DetailViewModel.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/21.
//

import Foundation

class DetailViewModel {
    let exercise: Exercise
    
    var isAvailable: Bool {
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return false }
        let video = "\(self.exercise.id).mov"
        let pose = "\(self.exercise.id).json"
        
        let isVideoExist = FileManager.default.fileExists(atPath: documentDirectoryUrl.appendingPathComponent(video).path)
        let isPoseExist = FileManager.default.fileExists(atPath: documentDirectoryUrl.appendingPathComponent(pose).path)
        
        if isVideoExist && isPoseExist {
            return true
        } else {
            if !isVideoExist {
                self.downloadingFileNamesStack.append(video)
                self.downloadingMessagesStack.append("영상 다운로드..")
            }
            if !isPoseExist {
                self.downloadingFileNamesStack.append(pose)
                self.downloadingMessagesStack.append("포즈 다운로드..")
            }
        }
        
        return false
    }
    
    var downloadingFileNamesStack: [String] = []
    var downloadingMessagesStack: [String] = []
    
    init(exercise: Exercise) {
        self.exercise = exercise
    }
}
