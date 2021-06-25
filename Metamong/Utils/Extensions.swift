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
    func msToTimeString(forStopWatch: Bool = false) -> String {
        var time = ""
        
        let hours = self / 3600000
        let minutes = (self - ( hours * 3600000)) / 60000
        let seconds = (self - ( hours * 3600000) - (minutes * 60000)) / 1000
        
        if forStopWatch {
            time = String(format: " %02d:%02d:%02d ", hours, minutes, seconds)
        } else {
            if hours > 0 {
                time += "\(hours)h"
            }
            if minutes > 0 {
                time += "\(minutes)m"
            }
            time += "\(seconds)s"
        }
        return time
    }
    
    var degreeToRadian: CGFloat {
        .pi * CGFloat(self) / 180.0
    }
}

extension CGColor {
    var getUIColor: UIColor {
        UIColor(cgColor: self)
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
    func toCGPoint(threshold: Float) -> CGPoint? {
        if self.confidence > threshold {
            return CGPoint(x: self.location.x, y: 1 - self.location.y)
        }
        return nil
    }
}

extension Date {
    var toMilliSeconds: Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
}

extension UIBezierPath {
    convenience init(center: CGPoint, radius: CGFloat) {
        self.init(ovalIn: CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius))
    }
}

extension URL {
    var extensionString: String {
        URL(fileURLWithPath: self.absoluteString).pathExtension
    }
}
