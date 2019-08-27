//
//  HinsGravityView.swift
//  Hins
//
//  Created by yantommy on 2017/5/6.
//  Copyright © 2017年 yantommy. All rights reserved.
//

//旋转后视图坐标变化
//http://blog.csdn.net/wenzeliang1013/article/details/52220829


import UIKit
import GPUImage

class HinsAssetBasePreView: UIView {

    var videoPreviewView: GPUImageView!
    var shadowView: UIView!
    var videoPreViewContainer: UIView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initViews()
    }
    
    func initViews(){
    
        self.backgroundColor = UIColor.clear
        shadowView = UIView(frame: self.bounds)
        shadowView.backgroundColor = UIColor.clear
        shadowView.addShadowsForLayer(color: UIColor.black)
        addSubview(shadowView)
        
        videoPreViewContainer = UIView(frame: self.bounds)
        videoPreViewContainer.backgroundColor = UIColor.cyan
        shadowView.addSubview(videoPreViewContainer)
        
        videoPreviewView = GPUImageView(frame: videoPreViewContainer.bounds)
        videoPreviewView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill
        videoPreviewView.isUserInteractionEnabled = false
        
        videoPreViewContainer.addSubview(videoPreviewView)
        videoPreViewContainer.layer.cornerRadius = 6
        videoPreViewContainer.clipsToBounds = true
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        shadowView.frame = self.bounds
        videoPreViewContainer.frame = self.bounds
        videoPreviewView.frame = videoPreViewContainer.bounds
    }

}
