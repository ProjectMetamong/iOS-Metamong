//
//  Exercise.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/21.
//

import Foundation

struct Exercise: Decodable {
    let id: Int
    let title: String
    let difficulty: String
    let creator: String
    let length: Int
    let description: String
    
    enum CodingKeys: String, CodingKey {
        case id = "exerciseId"
        case title = "title"
        case difficulty = "difficulty"
        case creator = "creator"
        case length = "videoLength"
        case description = "description"
    }
}

struct ExerciseResponseArray: Decodable {
    var exercises: [Exercise]
    
    enum CodingKeys: String, CodingKey {
        case exercises = "data"
    }
}
