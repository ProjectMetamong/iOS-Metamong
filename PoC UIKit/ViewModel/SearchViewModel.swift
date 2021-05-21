//
//  SearchViewModel.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/21.
//

import Foundation

class SearchViewModel {
    var exercises: [Exercise] = [
        Exercise(id: "aaa",
                 thumbnailURL: "https://globaljabar.com/wp-content/uploads/2021/02/xbreak-workout_602724-1.jpg.pagespeed.ic_.v8byD7su-e-1.jpg",
                 title: "요가",
                 difficulty: "초급자",
                 creator: "심으뜸",
                 length: 1200,
                 description: "심신안정에 도움이되는 요가 기본자세에 대해 알아봅니다."),
        Exercise(id: "bbb",
                 thumbnailURL: "https://www.exercise.co.uk/wp/wp-content/uploads/2019/04/Compound-Exercise-Workout.jpg",
                 title: "데드리프트",
                 difficulty: "고급자",
                 creator: "김계란",
                 length: 530,
                 description: "바닥에 놓여있는 중량을 들어올리는 데드리프트에 대해 알아봅니다."),
    ]
}
