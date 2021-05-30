//
//  SearchViewModel.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/21.
//

import Foundation

class SearchViewModel {
    var exercises: [Exercise] = [
        Exercise(title: "요가",
                 difficulty: "초급",
                 creator: "심으뜸",
                 length: 1200123,
                 description: "심신안정에 도움이되는 요가 기본자세에 대해 알아봅니다."),
        Exercise(title: "데드리프트",
                 difficulty: "고급",
                 creator: "김계란",
                 length: 530000,
                 description: "바닥에 놓여있는 중량을 들어올리는 데드리프트에 대해 알아봅니다."),
        Exercise(title: "팔굽혀펴기",
                 difficulty: "초급",
                 creator: "김계란",
                 length: 301000,
                 description: "어디서나 할 수 있는 가장 기초적인 가슴운동, 팔굽혀펴기에 대해 배워봅시다."),
        Exercise(title: "윗몸일으키기",
                 difficulty: "초급",
                 creator: "김계란",
                 length: 300,
                 description: "어디서나 할 수 있는 가장 기초적인 복근운동, 윗몸일으키기에 대해 배워봅시다."),
        Exercise(title: "동해물과백두산이마르고닳도록하느님이보우하사우리나라만세무궁화삼천리화려강산대한사람대한으로길이보전하세",
                 difficulty: "고급",
                 creator: "동해물과백두산이마르고닳도록하느님이보우하사우리나라만세무궁화삼천리화려강산대한사람대한으로길이보전하세",
                 length: 320319432,
                 description: "동해물과백두산이마르고닳도록하느님이보우하사우리나라만세무궁화삼천리화려강산대한사람대한으로길이보전하세"),
    ]
}
