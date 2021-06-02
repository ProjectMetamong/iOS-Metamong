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
    
    var isUploadButtonActive: Observable<Bool> {
        return Observable.combineLatest(thumbnailImage, title, creator, difficulty, length, description)
            .map { thumbnailImage, title, creator, difficulty, length, description in
                return thumbnailImage != nil && title.count > 0 && creator.count > 0 && difficulty.count > 0 && length != nil && description.count > 0
            }
    }
    
    func upload() {
        // todo : 입력된 정보들로 exercise 객체를 만든다.
        // id가 생성된다.
        APIService.uploadExercise(title: self.title.value, difficulty: self.difficulty.value, creator: self.creator.value, videoLength: self.length.value!, description: self.description.value) { exerciseId in
            guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            let videoUrl = documentDirectoryUrl.appendingPathComponent("temp.mov")
            let poseUrl = documentDirectoryUrl.appendingPathComponent("temp.json")
            
            // todo : 선택된 사진을 업로드한다.
            AWSS3Manager.shared.uploadImage(image: self.thumbnailImage.value!, newName: exerciseId, compressionQuality: 0.75) { progress in
                print(progress)
            } completion: { url, error in
            }
            
            // todo : 촬영된 영상을 업로드한다.
            AWSS3Manager.shared.uploadVideo(videoUrl: videoUrl, newName: exerciseId) { progress in
                print(progress)
            } completion: { link, error in
            }
            
            // todo : 촬영된 포즈정보를 업로드한다.
            AWSS3Manager.shared.uploadOtherFile(fileUrl: poseUrl, newName: exerciseId, conentType: ".json") { progress in
                print(progress)
            } completion: { link, error in
            }
        }
    }
}
