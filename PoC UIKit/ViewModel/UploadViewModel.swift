//
//  UploadViewModel.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/28.
//

import Foundation
import RxRelay
import RxSwift

class UploadViewModel {
    var thumbnailImage = BehaviorRelay<UIImage?>(value: nil)
    let title = BehaviorRelay<String>(value: "")
    let creator = BehaviorRelay<String>(value: "")
    let difficulty = BehaviorRelay<String>(value: "")
    let length = BehaviorRelay<String>(value: "")
    let description = BehaviorRelay<String>(value: "")
    
    var isUploadButtonActive: Observable<Bool> {
        return Observable.combineLatest(thumbnailImage, title, creator, difficulty, description)
            .map { thumbnailImage, title, creator, difficulty, description in
                return thumbnailImage != nil && title.count > 0 && creator.count > 0 && difficulty.count > 0 && description.count > 0
            }
    }
    
    func upload() {
        // todo : 입력된 정보들로 exercise 객체를 만든다.
        // id가 생성된다.
        
        // todo : 선택된 사진을 업로드한다.
        // 선택된 사진을 id.jpeg로 변경하여 업로드.
        // image.jpegData(compressionQuality: 0.75) 이용
        
        // todo : 촬영된 영상을 업로드한다.
        // 일단 temp.mov로 저장되어있는것을 id.mov로 변경하여 업로드.
        
        // todo : 촬영된 포즈정보를 업로드한다.
        // 일단 temp.json으로 저장되어있는것을 id.json으로 변경하여 업로드.
        
        // todo : exercise 정보를 서버에 업로드한다.
    
    }
}
