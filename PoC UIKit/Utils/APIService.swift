//
//  APIService.swift
//  Metamong
//
//  Created by Seunghun Yang on 2021/06/02.
//

import Foundation
import UIKit
import RxSwift

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
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
            }
            if let data = data {
                let responseDict = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                guard let resposneDict = responseDict else { return }
                let exerciseId = String(resposneDict["data"] as! Int64)
                completion(exerciseId)
            }
        }.resume()
    }
    
    static func fetchExercise(keyword: String? = nil, onComplete: @escaping (Result<Data, Error>) -> Void) {
        let stringURL = keyword == nil ? APIBaseUrl + APIGetAll : APIBaseUrl + APISearch + keyword!
        let apiURL = URL(string: stringURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)
        
        guard let apiURL = apiURL else { return }
        print(apiURL)
        URLSession.shared.dataTask(with: apiURL) { data, response, error in
            if let error = error {
                onComplete(.failure(error))
                return
            }
            guard let data = data else {
                let httpResponse = response as! HTTPURLResponse
                onComplete(.failure(NSError(domain: "no data",
                                            code: httpResponse.statusCode,
                                            userInfo: nil)))
                return
            }
            onComplete(.success(data))
        }.resume()
    }
    
    static func fetchExerciseRx(keyword: String? = nil) -> Observable<Data> {
        return Observable.create() { emitter in
            fetchExercise(keyword: keyword) { result in
                switch result {
                case .success(let data) :
                    emitter.onNext(data)
                    emitter.onCompleted()
                case .failure(let err) :
                    emitter.onError(err)
                }
            }
            return Disposables.create()
        }
    }
}
