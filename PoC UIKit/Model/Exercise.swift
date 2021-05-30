//
//  Exercise.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/21.
//

import Foundation

struct Exercise {
    let id: UUID
    let title: String
    let difficulty: String
    let creator: String
    let length: Int
    let description: String
    
    init(title: String, difficulty: String, creator: String, length: Int, description: String) {
        self.id = UUID()
        self.title = title
        self.difficulty = difficulty
        self.creator = creator
        self.length = length
        self.description = description
    }
}
