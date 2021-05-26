//
//  RecordViewModel.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/26.
//

import Foundation

class RecordViewModel {
    var poses: [Int: CodablePose] = [:]
    
    func encodePoses() {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(self.poses) {
            guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            let fileUrl = documentDirectoryUrl.appendingPathComponent("test.json")
            
            do {
                try jsonData.write(to: fileUrl, options: [])
            } catch {
                print(error)
            }
        }
    }
}
