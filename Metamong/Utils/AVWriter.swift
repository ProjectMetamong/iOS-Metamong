//
//  AVWriter.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/27.
//

import UIKit
import AVFoundation

protocol AVWriterDelegate {
    func updateRecordingTime(ms: Int)
}

class AVWriter : NSObject {
    
    var delegate: AVWriterDelegate?
    
    private var fileName: String
    private var assetWriter: AVAssetWriter!
    private var videoInput: AVAssetWriterInput!
    private var audioInput: AVAssetWriterInput!
    private var presentationStartTime: CMTime = CMTime.zero
    private(set) var recordingTime: Int = 0
    
    init(height: Int, width: Int, channels: Int, samples: Float64, saveAs fileName: String){
        self.fileName = fileName
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileUrl = documentDirectoryUrl.appendingPathComponent("\(self.fileName).mov")
        try? FileManager.default.removeItem(at: fileUrl)
        assetWriter = try? AVAssetWriter(outputURL: fileUrl, fileType: AVFileType.mov)
        
        let videoOutputSettings: Dictionary<String, AnyObject> = [AVVideoCodecKey : AVVideoCodecType.h264 as AnyObject,
                                                                  AVVideoWidthKey : width as AnyObject,
                                                                  AVVideoHeightKey : height as AnyObject]
        
        let audioOutputSettings: Dictionary<String, AnyObject> = [AVFormatIDKey : kAudioFormatMPEG4AAC as AnyObject,
                                                                  AVNumberOfChannelsKey : channels as AnyObject,
                                                                  AVSampleRateKey : samples as AnyObject,
                                                                  AVEncoderBitRateKey : 128000 as AnyObject]
        
        videoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoOutputSettings)
        videoInput.expectsMediaDataInRealTime = true
        assetWriter.add(videoInput)
        
        audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioOutputSettings)
        audioInput.expectsMediaDataInRealTime = true
        assetWriter.add(audioInput)
    }
    
    func stop(completion: @escaping (() -> Void)) {
        if self.assetWriter.status == .writing {
            self.assetWriter?.finishWriting(completionHandler: {
                completion()
            })
        }
    }
    
    func cropAndSave(cutoffLength: Float, isSucceed: @escaping ((Bool) -> Void), completion: @escaping (() -> Void)) {
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let sourceUrl = documentDirectoryUrl.appendingPathComponent("\(self.fileName).mov")
        let asset = AVAsset(url: sourceUrl)
        let length = Float(asset.duration.value) / Float(asset.duration.timescale)
        let endTime = Double(length - cutoffLength)
        
        if endTime > 0 {
            isSucceed(true)
            guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            let croppedUrl = documentDirectoryUrl.appendingPathComponent("\(self.fileName).mov")
            try? FileManager.default.removeItem(at: croppedUrl)

            let timeRange = CMTimeRange(start: CMTime(seconds: 0, preferredTimescale: 1000), end: CMTime(seconds: endTime, preferredTimescale: 1000))
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {return}
            exportSession.outputURL = croppedUrl
            exportSession.outputFileType = .mov
            exportSession.timeRange = timeRange
            exportSession.exportAsynchronously(completionHandler: completion)
        } else {
            isSucceed(false)
            completion()
        }
    }
    
    func write(sampleBuffer: CMSampleBuffer, isVideoData: Bool){
        if CMSampleBufferDataIsReady(sampleBuffer) {
            if self.assetWriter.status == .unknown && isVideoData{
                self.presentationStartTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                self.assetWriter?.startWriting()
                self.assetWriter?.startSession(atSourceTime: self.presentationStartTime)
            }
            
            if self.assetWriter.status == .writing {
                let targetInput: AVAssetWriterInput? = isVideoData ? videoInput : audioInput
                guard let input = targetInput else { return }
                if input.isReadyForMoreMediaData {
                    input.append(sampleBuffer)
                }
                self.recordingTime = Int(CMTimeGetSeconds(CMTimeSubtract(sampleBuffer.presentationTimeStamp, self.presentationStartTime)) * 1000)
                delegate?.updateRecordingTime(ms: self.recordingTime)
            }
        }
    }
}
