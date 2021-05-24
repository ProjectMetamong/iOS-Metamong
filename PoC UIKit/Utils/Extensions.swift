//
//  Extensions.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/21.
//

import Foundation
import UIKit
import Vision

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

extension UINavigationController {
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
            popToViewController(vc, animated: animated)
        }
    }
}

extension VNRecognizedPoint {
    func toCGPoint() -> CGPoint {
        return CGPoint(x: self.location.x, y: 1 - self.location.y)
    }
}
