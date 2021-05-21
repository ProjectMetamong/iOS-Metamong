//
//  Exercise.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/21.
//

import Foundation

struct Exercise {
    let id: String
    let thumbnailURL: URL?
    let title: String
    let difficulty: String
    let creator: String
    let length: String
    let description: String
    
    init(id: String, thumbnailURL: String, title: String, difficulty: String, creator: String, length: Int, description: String) {
        self.id = id
        self.thumbnailURL = URL(string: thumbnailURL)
        self.title = title
        self.difficulty = difficulty
        self.creator = creator
        self.length = length.toTimeString()
        self.description = description
    }
}
