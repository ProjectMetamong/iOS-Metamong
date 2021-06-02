//
//  UploadViewModel.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/28.
//

import Foundation
import RxRelay
import RxSwift
import AWSCore
import AWSCognito
import AWSS3

class UploadViewModel {
    let thumbnailImage = BehaviorRelay<UIImage?>(value: nil)
    let title = BehaviorRelay<String>(value: "")
    let creator = BehaviorRelay<String>(value: "")
    let difficulty = BehaviorRelay<String>(value: "")
    let length = BehaviorRelay<Int?>(value: nil)
    let description = BehaviorRelay<String>(value: "")
    
    let progressHudDescription = BehaviorRelay<String>(value: "정보 업로드..")
    let progress = BehaviorRelay<Double>(value: 0)
    
    var isUploadButtonActive: Observable<Bool> {
        return Observable.combineLatest(thumbnailImage, title, creator, difficulty, length, description)
            .map { thumbnailImage, title, creator, difficulty, length, description in
                return thumbnailImage != nil && title.count > 0 && creator.count > 0 && difficulty.count > 0 && length != nil && description.count > 0
            }
    }
    
    func upload(completion: @escaping (() -> Void)) {
        APIService.uploadExercise(title: self.title.value, difficulty: self.difficulty.value, creator: self.creator.value, videoLength: self.length.value!, description: self.description.value) { exerciseId in
            guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            let videoUrl = documentDirectoryUrl.appendingPathComponent("temp.mov")
            let poseUrl = documentDirectoryUrl.appendingPathComponent("temp.json")
            self.progress.accept(1.0)
            
            self.progressHudDescription.accept("썸네일 업로드..")
            self.progress.accept(0)
            AWSS3Manager.shared.uploadImage(image: self.thumbnailImage.value!, newName: exerciseId, compressionQuality: 0.75) { progress in
                self.progress.accept(progress)
            } completion: { _, _ in
                print("Image Uploaded!")
                
                self.progressHudDescription.accept("영상 업로드..")
                self.progress.accept(0)
                AWSS3Manager.shared.uploadVideo(videoUrl: videoUrl, newName: exerciseId) { progress in
                    self.progress.accept(progress)
                } completion: { _, _ in
                    print("Video Uploaded!")
                    
                    self.progressHudDescription.accept("포즈 업로드..")
                    self.progress.accept(0)
                    AWSS3Manager.shared.uploadOtherFile(fileUrl: poseUrl, newName: exerciseId, conentType: ".json") { progress in
                        self.progress.accept(progress)
                    } completion: { _, _ in
                        print("Pose Uploaded!")
                    }
                    completion()
                }
            }
        }
    }
}
