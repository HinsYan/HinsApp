//
//  HinsVideoCamera.swift
//  Hins
//
//  Created by yantommy on 2017/3/11.
//  Copyright © 2017年 BetterNet. All rights reserved.
//

import UIKit
import GPUImage

class HinsCamera: NSObject {
    
    //相机
    
    static let shared: HinsCamera = HinsCamera()
    
    var videoCamera: GPUImageVideoCamera = {
        
        let videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.high.rawValue, cameraPosition: .front)!
        videoCamera.outputImageOrientation = .portrait
        //镜象
        videoCamera.horizontallyMirrorFrontFacingCamera = true
        
        //防抖动配置
        let captureConnect = videoCamera.videoCaptureConnection()!
        let device = videoCamera.inputCamera!
        if captureConnect.isVideoStabilizationSupported {
            
            do{ try device.lockForConfiguration() }catch{ print(error.localizedDescription) }
            
            captureConnect.preferredVideoStabilizationMode = .standard
            device.unlockForConfiguration()
        }
        
        //镜头信息
        let dic = (videoCamera.captureSession.outputs.last as! AVCaptureVideoDataOutput).videoSettings as NSDictionary
        
        let width = dic.object(forKey: "Width") as! CGFloat
        let height = dic.object(forKey: "Height") as! CGFloat
        
        print("镜头宽度\(width)")
        print("镜头高度\(height)")
        
        videoCamera.audioEncodingTarget = nil
        //MARK:- 防治添加声音录制时卡顿
        videoCamera.addAudioInputsAndOutputs()
        
        return videoCamera
        
        
    }()
    
    //视频写入
    var videoWriter: GPUImageMovieWriter!
    
    
    override init() {
        super.init()
        readyToNextVideoWriter()
        
    }
    
    
    func getCameraPresetSize() -> CGSize {
        
        //镜头信息（注意视频和音频的添加顺序不同，outputs数组的对象顺序也会不同，）
        let dic = (videoCamera.captureSession.outputs.first as! AVCaptureVideoDataOutput).videoSettings as NSDictionary
        
        let width = dic.object(forKey: "Width") as! CGFloat
        let height = dic.object(forKey: "Height") as! CGFloat
        
        print("镜头宽度\(width)")
        print("镜头高度\(height)")
        return CGSize(width: width, height: height)
    }
    
    
    
}

extension HinsCamera {
    
    
    func startToRecord(Orientation: UIDeviceOrientation) {
        
        
        //        video =
        //
        //        video.exceptPreviewOrientation = Orientation
        
        
        //检差路径是否被占用
        self.checkWriteFileURLCorrect(url: videoWriter.assetWriter.outputURL)
        
        
        //MARK:- Step4 加入滤镜到Writter
        HinsFilterManager.currentFilter.addTarget(videoWriter)
        
        let startTime: DispatchTimeInterval = .milliseconds(500)
        let queue = DispatchQueue(label: "com.BetterNet.app.syc.captureWriteVideo")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + startTime) {
            self.videoWriter.startRecording()
        }
        
    }
    
    
    
    
    func endToRecoed(handle: @escaping (_ recordedURL: URL) -> Void) {
        
        //移除绑定
        HinsFilterManager.currentFilter.removeTarget(self.videoWriter)
        videoCamera.audioEncodingTarget = nil
        
        videoWriter.finishRecording {
            
            self.getFileSizeFormURL(self.videoWriter.assetWriter.outputURL)
            handle(self.videoWriter.assetWriter.outputURL)
            self.readyToNextVideoWriter()
        }
    }
    
    func getFileSizeFormURL(_ url: URL) -> CGFloat {
        
        var size: CGFloat = 0.0
        let fileManager = FileManager.default
        do {
            let attr = try fileManager.attributesOfItem(atPath: url.path)
            let sizeInt = attr[FileAttributeKey.size] as! UInt64
            size = CGFloat(sizeInt)/CGFloat(1024*1024)
            print("文件大小: \(size) M")
        } catch  {
            print("error :\(error)")
        }
        
        return CGFloat(size)
        
    }
    
    func checkWriteFileURLCorrect(url:URL) {
        
        //MARK:- Step3 判断URL是否被占用
        if FileManager.default.fileExists(atPath: url.path) {
            
            print("之前已存在文件路径:\(url)\n")
            
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
            }
            
            if FileManager.default.fileExists(atPath: url.path) {
                print("没有删除掉之前的文件\(url)\n")
            }else{
                print("删除掉了之前的文件\(url)\n")
            }
            
        }else{
            
            print("路径可用于写入文件：\(url)\n")
        }
        
    }

    
    
    
}

extension HinsCamera {
    
    func readyToNextVideoWriter(){
        
        /*
         
         卡顿原因：在使用GPUImageVideoCamera来录制的时候,可能需要分段录制,在GPUImage给出的视频录制Demo中直接只是录制一次，然而有时候需求可能是要录制多次，如果此时按照Demo的方法每次录制都要创建一个movieWriter,这样子的话每次都会在重新创建movieWriter并将它设置为videoCamera的audioEncodingTarget时候，界面都会卡顿一下.这是什么原因呢？因为videoCamera默认是不录制声音的，而每次创建movieWriter的时候都用到了movieWriter.hasAudioTrack = YES;,吊用这个之后videoCamera会自动去添加声音输入源,准备一些数据，所以这个过程会导致界面卡顿一下.
         解决方法：调用 addAudioInputsAndOutputs (录制的时候添加声音,添加输入源和输出源会暂时会使录制暂时卡住,所以在要使用声音的情况下要先调用该方法来防止录制被卡住)
         
         */
        
        //重新获取writer
        //MARK:- Step1 根据URL重新初始化配置Writter
        videoWriter = self.getVideoWriter()
        
        videoCamera.addAudioInputsAndOutputs()
        
        //因为这一句运算很浪费内存 所以避免第一针黑屏 再开始录制前要先准备好
        videoCamera.audioEncodingTarget = videoWriter
        
        
    }
    
    //通用链接
    fileprivate func getAssetVideoURL() -> URL? {
        
        let videoURL: URL!
        
        do{
            let date = Date()
            let formater = DateFormatter()
            formater.dateFormat = "YYYY-MM-dd-HH-mm-ss"
            let videoName = formater.string(from: date)
            
            let documentURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            //不能这样 因为不会自动创建CaptureCache这个文件夹 需要在之前手动创建
            //videoURL = documentURL.appendingPathComponent( "CaptureCache/" + videoName + ".mp4")
            videoURL = documentURL.appendingPathComponent(videoName + ".mp4")
            
            return videoURL
            
        }catch{
            
            print("创建视频保存路径失败，错误如下:\(error.localizedDescription)")
            return nil
            
        }
        
        
    }
    
    //通用写入
    fileprivate func getVideoWriter() -> GPUImageMovieWriter {
        
        //        video = HinsAssetVideo(cacheURL: self.getAssetVideoURL()!)
        let sizeForCameraPreset = self.getCameraPresetSize()
        let writer = GPUImageMovieWriter(movieURL: self.getAssetVideoURL()!, size: CGSize(width: sizeForCameraPreset.height, height: sizeForCameraPreset.width))!
        //写入配置
        writer.encodingLiveVideo = true
        
        //        writer.shouldPassthroughAudio = true
        //        writer.hasAudioTrack = true
        
        return writer
        
    }
    
}






