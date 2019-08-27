//
//  HinsAssetVideo.swift
//  Hins
//
//  Created by yantommy on 2017/3/20.
//  Copyright © 2017年 BetterNet. All rights reserved.
//

import UIKit
import GPUImage

class HinsAssetBase: NSObject {

    var cacheURL: URL!
    var savedURL: URL!
    
    var exceptSize: CGSize!
    var exceptPreviewOrientation = UIDeviceOrientation.portrait
    
    
    override init() {
        super.init()
        
    }
    
    init(cacheURL: URL) {
        super.init()
        
        self.cacheURL = cacheURL
        self.savedURL = HinsAssetVideo.getVideoSavedURLString()
        
    }
    
    
    func checkVideoIsSaved() -> Bool {
        
        //MARK:- Step3 判断URL是否被占用
        if FileManager.default.fileExists(atPath: savedURL.path) {
            print("文件已经保存-\(savedURL)")
            return true
            
        }else{
            print("文件没有保存-\(savedURL)")
            return false
        }
        
    }
    
    static func getVideoSavedURLString() -> URL? {
    
        let videoURL: URL!
        
        do{
            //统一导出相同的名字
            let videoName = "HinsAppMadeThisVideo"
            
            let documentURL = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            videoURL = documentURL.appendingPathComponent(videoName + ".mp4")
            
            return videoURL
            
        }catch{
            
            print("创建视频保存路径失败")
            return nil
            
        }
 
    }
    
}
