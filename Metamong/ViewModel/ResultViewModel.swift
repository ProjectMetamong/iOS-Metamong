//
//  ResultViewModel.swift
//  Metamong
//
//  Created by Seunghun Yang on 2021/06/01.
//

import RxRelay
import RxSwift

class ResultViewModel {
    var score = BehaviorRelay<Int?>(value: nil)
    
    init(score: Int) {
        self.score.accept(score)
    }
}
