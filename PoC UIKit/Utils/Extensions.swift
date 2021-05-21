//
//  Extensions.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/21.
//

import Foundation
import UIKit

extension Int {
    func toTimeString() -> String {
        var time = ""
        
        let hours = self / 3600
        let minutes = (self - (hours * 3600)) / 60
        let seconds = self - (hours * 3600) - (minutes * 60)
        
        if hours > 0 {
            time += "\(hours)h"
        }
        if minutes > 0 {
            time += "\(minutes)m"
        }
        time += "\(seconds)s"
        
        return time
    }
}
