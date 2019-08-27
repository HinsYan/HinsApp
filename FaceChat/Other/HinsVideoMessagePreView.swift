//
//  HinsAssetVideoPreView.swift
//  Hins
//
//  Created by yantommy on 2017/6/25.
//  Copyright © 2017年 yantommy. All rights reserved.
//

import UIKit
import GPUImage

class HinsVideoMessagePreView: HinsAssetBasePreView {

    var moviePlayerRate: Float = 1.0
    var isRepeat = true
    
    //对内可读写 对外只读
    fileprivate(set) var isPlaying = false
    
    var assetVideo: HinsAssetVideo? = nil {
        didSet{
            guard let _ = assetVideo else {
                print("Not Have Video To Prepare")
                return
            }
            prepareForPlayVideo(url: assetVideo!.cacheURL!)
        }
    }
    
    //播放视频
    var moviePlayer: AVPlayer!
    var moviePlayItem: AVPlayerItem!
    var moviePlayerLayer: AVPlayerLayer!
    var resourceLoader: ShortMediaResourceLoader!

    //进度检测
    var timerObserver: Any!
    var progressLine: UIProgressView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func initViews() {
        super.initViews()
        progressLine = UIProgressView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 10))
        progressLine.progressViewStyle = .bar
        progressLine.progressTintColor = UIColor.white
        addSubview(progressLine)

    }
    
    
    func prepareForPlayVideo(url: URL) {
        
        resourceLoader = ShortMediaResourceLoader()
        moviePlayItem = resourceLoader.playItem(with: url)
        moviePlayer = AVPlayer(playerItem: moviePlayItem)
        moviePlayerLayer = AVPlayerLayer(player: moviePlayer)
        moviePlayerLayer.frame = self.bounds
        moviePlayerLayer.videoGravity = .resizeAspectFill
        self.videoPreviewView.layer.addSublayer(moviePlayerLayer)
        addNotificationAndObserver()
   
    }
    
    
    func startPlayVideo() {
        guard let _ = self.moviePlayer else { return }
        print("开始播放")
        self.moviePlayer.seek(to: CMTime(value: 0, timescale: 300))
        self.moviePlayer.playImmediately(atRate: self.moviePlayerRate)
        self.isPlaying = true
        
    }
    
    func pausePlayVideo() {
        
        guard let _ = moviePlayer else { return }
        moviePlayer.pause()
        isPlaying = false
    }

    func resumePlayVideo() {
    
        guard let _ = moviePlayer else { return }
        moviePlayer.play()
        isPlaying = true
    }

    func stopPlayVideo() {
        removeNotificationAndObserver()
        guard let _ = self.moviePlayer else { return }
        moviePlayer.pause()
        resourceLoader.endLoading()
        let asset = moviePlayItem.asset as! AVURLAsset
        asset.resourceLoader.setDelegate(nil, queue: DispatchQueue.main)
        moviePlayerLayer.removeFromSuperlayer()
        resourceLoader = nil
        moviePlayItem = nil
        moviePlayer = nil
        moviePlayerLayer = nil
    }
    
    deinit {
        
        stopPlayVideo()
        print("销毁了")
    }

}


//MARK: -播放状态，通知等
extension HinsVideoMessagePreView {
    
    //MARK: -添加通知
    func addNotificationAndObserver(){
        
        //检测播放状态
        moviePlayer.currentItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        //检测播放进度
        addProgressObserve()
        
        //检测播放完成及前后台切换
        NotificationCenter.default.addObserver(self, selector: #selector(self.currentPlayItemEndPlayToEndTime(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.moviePlayer.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterBackgroundNotification), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.willEnterForegroundNotification), name: UIApplication.willEnterForegroundNotification, object: nil)
        
    }
    
    //MARK: -移除通知
    func removeNotificationAndObserver(){
        guard let _ = self.moviePlayer else { return }
        moviePlayer.currentItem?.cancelPendingSeeks()
        moviePlayer.currentItem?.asset.cancelLoading()
        
        moviePlayer.removeTimeObserver(timerObserver)
        moviePlayer.currentItem?.removeObserver(self, forKeyPath: "status")
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        
    }
    
    
    //MARK: -播放状态监测
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //获取观察对象
        guard let object = object as? AVPlayerItem  else { return }
        
        if keyPath == "status" {
            
            switch object.status {
                
            case .readyToPlay:
                print("已经准备好播放，视频总长度为\(CMTimeGetSeconds((moviePlayer.currentItem?.duration)!))")
            case .failed:
                print("未准备好播放")
            default:
                print("不明原因为播放")
            }
            
        }
        
    }
    
    //MARK: -进度检测
    func addProgressObserve(){
        
        timerObserver = self.moviePlayer.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 30), queue: DispatchQueue.main) { [weak self] (time) in
            
            
            //print(time)
            //上面检测方法只在Player播放时会回调，但暂停播放时会存在延迟，所以手动控制纪录播放状态
            if self!.isPlaying {
            
            let currentDuration = CMTimeGetSeconds(time)
            let totalDuration = CMTimeGetSeconds(self!.moviePlayer.currentItem!.duration)
            
            let percentDuration = currentDuration/totalDuration
            
            if percentDuration == 0 {
                self!.progressLine.setProgress(Float(percentDuration), animated: false)
            }else{
                self!.progressLine.setProgress(Float(percentDuration), animated: true)
            }
           
            }
            
            
        }
        
    }
    
    //MARK: -通知提醒 播放完成循环播放
    @objc func currentPlayItemEndPlayToEndTime(_ sender: AVPlayerItem) {
        
        if isRepeat {
            print("播放完成，循环再次播放")
            moviePlayer.currentItem?.seek(to: CMTime(value: 0, timescale: 1))
            moviePlayer.playImmediately(atRate: moviePlayerRate)
        }else{
            isPlaying = false
            print("单次播放完成")
        }
        
    }
    
    //MARK: -前后台
    @objc func willEnterForegroundNotification() {
        if moviePlayer != nil {
            moviePlayer.playImmediately(atRate: moviePlayerRate)
        }
    }
    @objc func didEnterBackgroundNotification() {
        if moviePlayer != nil {
            moviePlayer.pause()
        }
    }
    
}



