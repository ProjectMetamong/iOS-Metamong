//
//  SearchViewModel.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/21.
//

import Foundation
import RxSwift
import RxRelay
import Nuke

class SearchViewModel {
    lazy var exerciseObservable = BehaviorRelay<[Exercise]>(value: [])
    var recentKeyword: String?
    
    init() {
        self.searchExercises()
    }
    
    func searchExercises(keyword: String? = nil) {
        self.recentKeyword = keyword
        ImageCache.shared.removeAll()
        _ = APIService.fetchExerciseRx(keyword: keyword)
            .map { data -> [Exercise] in
                let exerciseResponseArray = try! JSONDecoder().decode(ExerciseResponseArray.self, from: data)
                return exerciseResponseArray.exercises
            }
            .take(1)
            .subscribe(onNext: {
                self.exerciseObservable.accept($0)
            })
    }
    
    func refreshExercises() {
        guard let keyword = recentKeyword else { return }
        self.searchExercises(keyword: keyword)
    }
}
