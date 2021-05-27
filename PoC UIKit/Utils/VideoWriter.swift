//
//  VideoWriter.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/27.
//

import UIKit
import AVFoundation


protocol VideoWriterDelegate {
    func changeRecordingTime(s: Int64)
    func finishRecording(fileUrl: URL)
}

class VideoWriter : NSObject {
    
    var delegate: VideoWriterDelegate?
    
    fileprivate var writer: AVAssetWriter!
    fileprivate var videoInput: AVAssetWriterInput!
    fileprivate var audioInput: AVAssetWriterInput!
    
    fileprivate var lastTime: CMTime!
    fileprivate var offsetTime = CMTime.zero
    fileprivate var recordingTime:Int64 = 0
    
    enum status {
        case StartRecording
        case Writing
    }
    
    var writerStatus: status = .StartRecording
    
    init(height:Int, width:Int, channels:Int, samples:Float64, recordingTime:Int64){
        
        self.recordingTime = recordingTime
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as String
        let filePath : String? = "\(documentsDirectory)/test.mov"
        if FileManager.default.fileExists(atPath: filePath!) {
            try? FileManager.default.removeItem(atPath: filePath!)
        }

        writer = try? AVAssetWriter(outputURL: URL(fileURLWithPath: filePath!), fileType: AVFileType.mov)
        
        let videoOutputSettings: Dictionary<String, AnyObject> = [
            AVVideoCodecKey : AVVideoCodecType.h264 as AnyObject,
            AVVideoWidthKey : width as AnyObject,
            AVVideoHeightKey : height as AnyObject
        ];
        
        videoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoOutputSettings)
        videoInput.expectsMediaDataInRealTime = true
        writer.add(videoInput)
        
        let audioOutputSettings: Dictionary<String, AnyObject> = [
            AVFormatIDKey : kAudioFormatMPEG4AAC as AnyObject,
            AVNumberOfChannelsKey : channels as AnyObject,
            AVSampleRateKey : samples as AnyObject,
            AVEncoderBitRateKey : 128000 as AnyObject
        ]
        
        audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioOutputSettings)
        audioInput.expectsMediaDataInRealTime = true
        writer.add(audioInput)
    }
    
    func RecodingTime() -> CMTime {
        return CMTimeSubtract(lastTime, offsetTime)
    }
    
    func stop() {
        self.writer?.finishWriting {
            print("DONE!!!")
        }
    }
    
    func write(sampleBuffer: CMSampleBuffer, isVideo: Bool){
        print("???")
        if CMSampleBufferDataIsReady(sampleBuffer) {
            if isVideo && self.writerStatus == .StartRecording {
                print("start writing")
                offsetTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                writer?.startWriting()
                writer?.startSession(atSourceTime: CMTime.zero)
                self.writerStatus = .Writing
            }
            if writer.status == .writing {
                print("...writing")
                var copyBuffer : CMSampleBuffer?
                var count: CMItemCount = 1
                var info = CMSampleTimingInfo()
                CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, entryCount: count, arrayToFill: &info, entriesNeededOut: &count)
                info.presentationTimeStamp = CMTimeSubtract(info.presentationTimeStamp, offsetTime)
                CMSampleBufferCreateCopyWithNewTiming(allocator: kCFAllocatorDefault,sampleBuffer: sampleBuffer,sampleTimingEntryCount: 1,sampleTimingArray: &info,sampleBufferOut: &copyBuffer)
                
                lastTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                
                if isVideo {
                    if (videoInput?.isReadyForMoreMediaData)! {
                        videoInput?.append(copyBuffer!)
                    }
                }else{
                    if (audioInput?.isReadyForMoreMediaData)! {
                        audioInput?.append(copyBuffer!)
                    }
                }
                //delegate?.changeRecordingTime(s: RecodingTime().value)
            }
        }
    }
}
