//
//  BTNCameraView.swift
//  BetterNet
//
//  Created by yantommy on 2016/12/31.
//  Copyright © 2016年 yantommy. All rights reserved.
//

import UIKit
import GPUImage

protocol BTNCameraViewDelegate: class {
    func didEndMaxtimeCaptre(avatarView: BTNCameraView)
    
}

extension BTNCameraViewDelegate {
    func didEndMaxtimeCaptre(avatarView: BTNCameraView) {}
}



class BTNCameraView: UIView {
    
    //聚焦
    var tapGesture: UITapGestureRecognizer!
    var panGesture: UIPanGestureRecognizer!
    
    
    var filterView: GPUImageView!
    var filterSwitchCount:Int = 0
    
    var progressLayer: CAShapeLayer!
    var borderLayer: CAShapeLayer!
    var displayLink: CADisplayLink!
    
    weak var delegate: BTNCameraViewDelegate?
    
    var maxRecoderSecond: Int = 15
    var currentProgress:CGFloat = 0.0 {
        didSet {
            progressLayer.strokeEnd = currentProgress
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        initCamera()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initCamera()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func initCamera() {
    
        //输出视图
        filterView = GPUImageView(frame: self.bounds)
        filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill
        self.addSubview(filterView)
        self.sendSubviewToBack(filterView)
        
        //输出相应链
        HinsCamera.shared.videoCamera.addTarget(HinsFilterManager.currentFilter)
        HinsFilterManager.currentFilter.addTarget(filterView)
        HinsCamera.shared.videoCamera.startCapture()

        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.actionCamera(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        filterView.frame = self.bounds
        
        displayLink = CADisplayLink(target: self, selector: #selector(self.animationChange(_:)))
        displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
        displayLink.preferredFramesPerSecond = 60
        displayLink.isPaused = true
        
        borderLayer = CAShapeLayer()
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.white.withAlphaComponent(0.5).cgColor
        borderLayer.lineWidth = 6.0
        borderLayer.frame = self.bounds
        layer.addSublayer(borderLayer)
        let pathBorder = UIBezierPath(roundedRect: self.bounds, cornerRadius: kBTNWindowCornerRadii/2)
        borderLayer.path = pathBorder.cgPath

        progressLayer = CAShapeLayer()
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.cyan.cgColor
        progressLayer.lineWidth = 4.0
        progressLayer.strokeEnd = 0.0
        progressLayer.frame = self.bounds
        layer.addSublayer(progressLayer)
        
        let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: kBTNWindowCornerRadii/2)
        progressLayer.path = path.cgPath



    }
    
    @objc func animationChange(_ sender: CADisplayLink!) {
        let totalFrame = CGFloat(sender.preferredFramesPerSecond*maxRecoderSecond)
        currentProgress += CGFloat(1.0)/totalFrame
        if currentProgress >= 1.0 {
            endAnimation()
            if let delega = self.delegate {
                delega.didEndMaxtimeCaptre(avatarView: self)
            }
        }
    }
    
    
    
    func startAnimation() {
        displayLink.isPaused = false
        print("开始录制")

    }
    
    func endAnimation() {
        currentProgress = 0.0
        displayLink.isPaused = true
        print("结束录制")
    }
    
    deinit {
        displayLink.remove(from: RunLoop.main, forMode: RunLoop.Mode.default)
        displayLink.invalidate()
        displayLink = nil

    }
    
    
    @IBAction func actionFilter(_ sender: UIButton) {
        let lastIndex = filterSwitchCount % HinsFilterManager.allFilters.count
        HinsCamera.shared.videoCamera.removeTarget(HinsFilterManager.currentFilter)
        filterSwitchCount += 1
        let currentIndex = filterSwitchCount % HinsFilterManager.allFilters.count
        HinsFilterManager.currentFilter = HinsFilterManager.allFilters[currentIndex]
        HinsFilterManager.currentFilter.removeAllTargets()
        HinsCamera.shared.videoCamera.addTarget(HinsFilterManager.currentFilter)
        HinsFilterManager.currentFilter.addTarget(filterView)
    }

    @IBAction func actionCamera(_ sender: Any) {
        HinsCamera.shared.videoCamera.rotateCamera()
    }
    
  
}


