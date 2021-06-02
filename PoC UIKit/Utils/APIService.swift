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
        guard let url = URL(string: APIPostUrl) else { return }
        var request = URLRequest(url: url)
        
        let parameters: [String: Any] = [
            "title": title,
            "difficulty": difficulty,
            "creator": creator,
            "videoLength": videoLength,
            "description": description
        ]
        
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
            }
            if let id = data, let id = String(data: id, encoding: .utf8) {
                completion(id)
            }
        }
        task.resume()
    }
}
