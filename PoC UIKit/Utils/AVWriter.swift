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
    
    private var assetWriter: AVAssetWriter!
    private var videoInput: AVAssetWriterInput!
    private var audioInput: AVAssetWriterInput!
    private var presentationStartTime = CMTime.zero
    
    init(height: Int, width: Int, channels: Int, samples: Float64, saveAs fileName: String){
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileUrl = documentDirectoryUrl.appendingPathComponent("\(fileName).mov")
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
    
    func stop() {
        self.assetWriter?.finishWriting {
            print("Done!")
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
                let recordingTime = Int(CMTimeGetSeconds(CMTimeSubtract(sampleBuffer.presentationTimeStamp, self.presentationStartTime)) * 1000)
                delegate?.updateRecordingTime(ms: recordingTime)
            }
        }
    }
}
