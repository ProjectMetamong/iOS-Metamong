//
//  APIService.swift
//  Metamong
//
//  Created by Seunghun Yang on 2021/06/02.
//

import Foundation
import UIKit

class APIService {
    static func uploadExercise(title: String, difficulty: String, creator: String, videoLength: Int, description: String, completion: @escaping ((String) -> Void)) {
        guard let url = URL(string: APIBaseUrl + APICreate) else { return }
        var request = URLRequest(url: url)
        
        let parameters: [String: Any] = [
            "title": title,
            "difficulty": difficulty,
            "creator": creator,
            "videoLength": videoLength,
            "description": description
        ]
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
            }
            if let data = data {
                let responseDict = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                guard let resposneDict = responseDict else { return }
                let exerciseId = String(resposneDict["data"] as! Int64)
                completion(exerciseId)
            }
        }
        task.resume()
    }
}
