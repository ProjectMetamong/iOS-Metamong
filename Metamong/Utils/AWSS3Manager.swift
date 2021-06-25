//
//  AWSS3Manager.swift
//  Metamong
//
//  Created by Seunghun Yang on 2021/06/01.
//

import Foundation
import UIKit
import AWSS3 //1

typealias progressBlock = (_ progress: Double) -> Void
typealias completionBlock = (_ response: Any?, _ error: Error?) -> Void

class AWSS3Manager {
    
    static let shared = AWSS3Manager()
    private init () { }
    
    // Upload image using UIImage object
    func uploadImage(image: UIImage, newName: String, compressionQuality: CGFloat, progress: progressBlock?, completion: completionBlock?) {
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            let error = NSError(domain:"", code:402, userInfo:[NSLocalizedDescriptionKey: "invalid image"])
            completion?(nil, error)
            return
        }
        
        let tmpPath = NSTemporaryDirectory() as String
        let fileName: String = newName + ".jpeg"
        let filePath = tmpPath + "/" + fileName
        let fileUrl = URL(fileURLWithPath: filePath)
        
        do {
            try imageData.write(to: fileUrl)
            self.uploadfile(fileUrl: fileUrl, fileName: fileName, contenType: "image", progress: progress, completion: completion)
        } catch {
            let error = NSError(domain:"", code:402, userInfo:[NSLocalizedDescriptionKey: "invalid image"])
            completion?(nil, error)
        }
    }
    
    // Upload video from local path url
    func uploadVideo(videoUrl: URL, newName: String, progress: progressBlock?, completion: completionBlock?) {
        let fileName = self.generateFileName(fileUrl: videoUrl, newName: newName)
        self.uploadfile(fileUrl: videoUrl, fileName: fileName, contenType: "video", progress: progress, completion: completion) 
    }
    
    // Upload auido from local path url
    func uploadAudio(audioUrl: URL, newName: String, progress: progressBlock?, completion: completionBlock?) {
        let fileName = self.generateFileName(fileUrl: audioUrl, newName: newName)
        self.uploadfile(fileUrl: audioUrl, fileName: fileName, contenType: "audio", progress: progress, completion: completion)
    }
    
    // Upload files like Text, Zip, etc from local path url
    func uploadOtherFile(fileUrl: URL, newName: String, conentType: String, progress: progressBlock?, completion: completionBlock?) {
        let fileName = self.generateFileName(fileUrl: fileUrl, newName: newName)
        self.uploadfile(fileUrl: fileUrl, fileName: fileName, contenType: conentType, progress: progress, completion: completion)
    }
    
    // Get unique file name
    func generateFileName(fileUrl: URL, newName: String) -> String {
        return newName + "." + fileUrl.extensionString
    }
    
    //MARK:- AWS file upload
    private func uploadfile(fileUrl: URL, fileName: String, contenType: String, progress: progressBlock?, completion: completionBlock?) {
        let expression = AWSS3TransferUtilityUploadExpression()
        
        // Progress block
        expression.progressBlock = {(task, awsProgress) in
            guard let uploadProgress = progress else { return }
            DispatchQueue.main.async {
                uploadProgress(awsProgress.fractionCompleted)
            }
        }
        
        // Completion block
        var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
        completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                if error == nil {
                    let url = AWSS3.default().configuration.endpoint.url
                    let publicURL = url?.appendingPathComponent(AWSS3BucketName).appendingPathComponent(fileName)
                    print(String(describing: publicURL))
                    if let completionBlock = completion {
                        completionBlock(publicURL?.absoluteString, nil)
                    }
                } else {
                    if let completionBlock = completion {
                        completionBlock(nil, error)
                    }
                }
            })
        }
        
        // Start uploading using AWSS3TransferUtility
        let awsTransferUtility = AWSS3TransferUtility.default()
        awsTransferUtility.uploadFile(fileUrl, bucket: AWSS3BucketName, key: fileName, contentType: contenType, expression: expression, completionHandler: completionHandler).continueWith { (task) -> Any? in
            if let error = task.error {
                print(error.localizedDescription)
            }
            return nil
        }
    }
}
