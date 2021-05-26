//
//  ExerciseCamViewModel.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/26.
//

import Foundation

class ExerciseCamViewModel {
    var poses: [Int: CodablePose] = [:]
    
    init() {
        guard let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileUrl = documentsDirectoryUrl.appendingPathComponent("test.json")

        do {
            let data = try Data(contentsOf: fileUrl, options: [])
            let decoder = JSONDecoder()
            let jsonData = try? decoder.decode([Int: CodablePose].self, from: data)
            guard let decoded = jsonData else { return }
            self.poses = decoded
        } catch {
            print(error)
        }
    }
}
