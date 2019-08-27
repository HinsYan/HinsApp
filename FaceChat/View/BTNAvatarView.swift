//
//  BTNAvatarButton.swift
//  Chatter
//
//  Created by yantommy on 2017/1/1.
//  Copyright © 2017年 BetterNet. All rights reserved.
//

import UIKit
import BEMCheckBox

protocol BTNAvatarViewDelegate: class {
    func willStartScaleAnimation(avatarView: BTNAvatarView)
    func WillEndScaleAnimation(avatarView: BTNAvatarView)
    func didEndAllAniamtion(avatarView: BTNAvatarView, success: Bool)
    
}

extension BTNAvatarViewDelegate {
    func willStartScaleAnimation(avatarView: BTNAvatarView) {}
    func WillEndScaleAnimation(avatarView: BTNAvatarView) {}
    func didEndAllAniamtion(avatarView: BTNAvatarView, success: Bool) {}
}

class BTNAvatarView: UIView {
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    lazy var cancelView: UIImageView = {
        let cancel = UIImageView(image: UIImage(named: "iconClose")!)
        cancel.frame.size = CGSize(width: 50, height: 50)
        cancel.layer.position = imgViewAvatar.center
        cancel.layer.opacity = 0.0
        cancel.transform = CGAffineTransform.init(scaleX: 0.2, y: 0.2)
        
        addSubview(cancel)
        return cancel
    }()
    
    var longPressGesture: UILongPressGestureRecognizer!
    
    var imgViewAvatar: UIImageView!
    var progressView: BEMCheckBox!
    
    var borderLayer: CAShapeLayer!
    
    
    var cancelGesture: UITapGestureRecognizer!
    var delegate: BTNAvatarViewDelegate?
    
    
    var isSuccess = true
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initViews()
    }
    
    func initViews() {
        
        imgViewAvatar = UIImageView(frame: self.bounds)
        imgViewAvatar.layer.cornerRadius = imgViewAvatar.bounds.width/2
        imgViewAvatar.layer.masksToBounds = true
        imgViewAvatar.contentMode = .scaleAspectFill
        imgViewAvatar.clipsToBounds = true
        
        self.addSubview(imgViewAvatar)
        self.layer.cornerRadius = self.bounds.width/2
        self.clipsToBounds = false
        self.addShadowWith(color: UIColor.darkGray, opacity: nil, radius: 5, offset: CGSize.zero)
        
        progressView = BEMCheckBox(frame: imgViewAvatar.bounds)
        addSubview(progressView)
        progressView.boxType = .circle
        progressView.lineWidth = 4.0
        progressView.onAnimationType = .oneStroke
        progressView.offAnimationType = .oneStroke
        progressView.tintColor = UIColor.clear
        progressView.onTintColor = UIColor.yellow
        progressView.onFillColor = UIColor.yellow
        progressView.onCheckColor = UIColor.cyan
        progressView.animationDuration = 4.0
        progressView.delegate = self
        
//        borderLayer = CAShapeLayer()
//        borderLayer.fillColor = UIColor.clear.cgColor
//        borderLayer.strokeColor = UIColor.white.withAlphaComponent(0.3).cgColor
//        borderLayer.lineWidth = 4.0
//        borderLayer.frame = self.bounds
//        layer.addSublayer(borderLayer)


        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.actionCaptureVideo(_:)))
        longPressGesture.minimumPressDuration = 0.5
        self.addGestureRecognizer(longPressGesture)

        cancelGesture = UITapGestureRecognizer(target: self, action: #selector(self.actionCancel(_:)))
        cancelGesture.isEnabled = false
        self.addGestureRecognizer(cancelGesture)
        
    
    }
    // MARK: - Todo 待优化
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imgViewAvatar.frame = self.bounds
        imgViewAvatar.layer.cornerRadius = imgViewAvatar.bounds.width/2
        self.layer.cornerRadius = self.bounds.width/2
  
        progressView.frame = imgViewAvatar.bounds
        progressView.isEnabled = false
        
//        let pathBorder = UIBezierPath(ovalIn: self.bounds)
//        borderLayer.path = pathBorder.cgPath
//        borderLayer.frame = self.bounds

    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        

    }
}

// MARK: - 录制相关手势状态处理
extension BTNAvatarView {
    
    @objc func actionCaptureVideo(_ sender: UILongPressGestureRecognizer) {
        
        switch sender.state {
        case .began:
            self.readyForCapture()
        case .changed:
            print("此处随手势的移动调整相机焦距")
        default:
            self.finishCapture()
        }
    }
}



// MARK: - 录制状态
extension BTNAvatarView: BEMCheckBoxDelegate {

    func readyForCapture(){
        
        //通知代理 准备发送消息
        self.cancelGesture.isEnabled = true
        self.isSuccess = true
        if let delega = self.delegate {
            delega.willStartScaleAnimation(avatarView: self)
        }
        
        self.layer.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.0, options: [.allowUserInteraction,.curveEaseInOut], animations: {
            self.transform = CGAffineTransform.init(a: 1.3, b: 0, c: 0, d: 1.3, tx: 0, ty: 0)
        }) { (success) in
        }
        
    }
    
    func finishCapture(){
    
        
        //通知代理 当前消息应该发出
        if let delega = self.delegate {
            delega.WillEndScaleAnimation(avatarView: self)
        }
        self.cancelGesture.isEnabled = true
        self.layer.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.0, options: [.allowUserInteraction,.curveEaseInOut], animations: {
            self.imgViewAvatar.layer.opacity = 0.2
            self.cancelView.layer.opacity = 1.0
            self.cancelView.transform = CGAffineTransform.identity
            self.transform = CGAffineTransform.identity
        }) { (success) in
            
            UIView.animate(withDuration: 3.0, animations: {
                self.cancelView.layer.opacity  = 0.0
                self.cancelView.transform = CGAffineTransform.init(scaleX: 0.2, y: 0.2)
            }, completion: { (success) in
                //通知代理 当前消息应该发出
                self.cancelGesture.isEnabled = false
                if let delega = self.delegate {
                    if self.isSuccess {
                       delega.didEndAllAniamtion(avatarView: self, success: self.isSuccess)
                    }
                }
            })
            
        }
        
        progressView.layer.opacity = 1.0
        progressView.setOn(false, animated: false)
        progressView.setOn(true, animated: true)
    }
    

    @objc func actionCancel(_ sender: UITapGestureRecognizer!) {
        if progressView.on {
            self.isSuccess = false
            UIView.animate(withDuration: 0.3) {
                self.progressView.layer.opacity = 0.0
                self.cancelView.layer.opacity = 0.0
                self.cancelView.transform = CGAffineTransform.init(scaleX: 0.2, y: 0.2)
                self.imgViewAvatar.layer.opacity = 1.0
            }
            self.cancelGesture.isEnabled = false
            if let delega = self.delegate {
                delega.didEndAllAniamtion(avatarView: self, success: isSuccess)
            }
            
        }
    }
    
    func animationDidStop(for checkBox: BEMCheckBox) {
        if progressView.on {
            UIView.animate(withDuration: 0.3) {
                self.progressView.layer.opacity = 0.0
                self.imgViewAvatar.layer.opacity = 1.0
            }
        }
    }
}
