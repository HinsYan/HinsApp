//
//  HinsEditCardTransition.swift
//  Hins
//
//  Created by yantommy on 2017/6/27.
//  Copyright © 2017年 yantommy. All rights reserved.
//

import UIKit

@objc public enum HinsViewSwipeDirection: Int {
    
    case none = 0
    case swipeLeft
    case swipeRight
    case swipeUp
    case swipeDown
}


public protocol HinsEditCardTransitionDelegate: class {
    func willBgeinTransition(transition: HinsEditCardTransition, direction: HinsViewSwipeDirection)
    
    func didUpdateTransition(transition: HinsEditCardTransition, progress: CGFloat)
    
    func didEndTransition(transition: HinsEditCardTransition, isSuccess: Bool)
    
    
}

public extension HinsEditCardTransitionDelegate {
    func willBgeinTransition(transition: HinsEditCardTransition, direction: HinsViewSwipeDirection) {}
    func didUpdateTransition(transition: HinsEditCardTransition, progress: CGFloat) {}
    func didEndTransition(transition: HinsEditCardTransition, isSuccess: Bool) {}
}


public class HinsEditCardTransition: NSObject {

    var fromView: UIView! {
        didSet {
            panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureAction(_:)))
            fromView.addGestureRecognizer(panGesture)
        }
    }
    var toView: UIView!
    var scaleView: UIView?
    
    var isFinish = false
    
    var panGesture: UIPanGestureRecognizer!
    var swipeDirection: HinsViewSwipeDirection!
    
    
    weak var transitionDelegate: HinsEditCardTransitionDelegate?
    
    
    deinit {
        print("hhhhh")
    }
    
    init(fromView: UIView, toView: UIView, scaleView: UIView?) {
        super.init()
        
        self.fromView = fromView
        self.toView = toView
        self.scaleView = scaleView
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureAction(_:)))
        self.fromView.addGestureRecognizer(panGesture)
        
    }
    
    
    
    func startTransitionWith(direction: HinsViewSwipeDirection) {
        self.swipeDirection = direction
        if let delegate = transitionDelegate {
            delegate.willBgeinTransition(transition: self, direction: direction)
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 1.0, options: [.curveEaseIn], animations: {
            self.fromView.transform = CGAffineTransform.init(scaleX: 0.9, y: 0.9)
            self.toView.transform = CGAffineTransform.init(scaleX: 0.9, y: 0.9)
            self.toView.layer.opacity = 0.0
            
        }) { (success) in
           
            UIView.animate(withDuration: 0.3, animations: {
                let rotated = (direction == .swipeRight) ? CGFloat(M_PI_4/2) : CGFloat(-M_PI_4/2)
                let translated = (direction == .swipeRight) ? self.fromView.bounds.width*1.25 : -self.fromView.bounds.width*1.25
                self.fromView.transform = self.fromView.transform.rotated(by: rotated).translatedBy(x: translated, y: 0)
                self.toView.transform = CGAffineTransform.identity
                self.toView.layer.opacity = 1.0
            }, completion: { (success) in
                if let delegate = self.transitionDelegate {
                    delegate.didEndTransition(transition: self, isSuccess: true)
                }
            })
        }
        
        
    }
    
    
    
    
    @objc func panGestureAction(_ sender: UIPanGestureRecognizer) {
        
        let transitionPoint = sender.translation(in: sender.view)
        let progress = min(1.0, max(0, abs(transitionPoint.x/(sender.view?.bounds.width)!)))
        
        switch sender.state {
        case .began:
            
            print("transitionGesture开始识别方向")
            swipeDirection = sender.getPanGestureDirection()

            //只支持左滑
            if swipeDirection != .swipeLeft {
                return
            }
            
            if swipeDirection == .swipeLeft || swipeDirection == .swipeRight {

                //针对即将出现的View处理
                self.toView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                self.toView.layer.opacity = 0.0
                
                //缩放View
                if let scaleView = self.scaleView {
                    UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [.curveEaseInOut], animations: {
                        scaleView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                    }, completion: { (success) in
                    })
                }

            }
            
            //代理
            if let delegate = transitionDelegate {
                delegate.willBgeinTransition(transition: self, direction: swipeDirection)
            }
            
            
        case .changed:
           
            //只支持左滑
            if swipeDirection != .swipeLeft {
                return
            }
           
            //判断左右转场是否完成
            if swipeDirection == .swipeRight {
                isFinish = sender.velocity(in: sender.view).x > 0 ? true : false
            }
            if swipeDirection == .swipeLeft {
                isFinish = sender.velocity(in: sender.view).x < 0 ? true : false
            }
            
            if swipeDirection == .swipeDown {
                isFinish = sender.velocity(in: sender.view).y > 0 ? true : false
            }
            if swipeDirection == .swipeUp {
                isFinish = sender.velocity(in: sender.view).x < 0 ? true : false
            }
            
            if progress > 0.5 {
                isFinish = true
            }

        
            if let delegate = transitionDelegate {
                delegate.didUpdateTransition(transition: self, progress: progress)
            }
            
            
            if swipeDirection == .swipeLeft || swipeDirection == .swipeRight {
                //进度动画
                let transformAddRoate = CGAffineTransform(rotationAngle: swipeDirection == .swipeRight ? CGFloat(M_PI_4/2)*progress : CGFloat(-M_PI_4/2)*progress)
                let newTransform = transformAddRoate.translatedBy(x: swipeDirection == .swipeRight ? self.fromView.bounds.width*progress*1.25 : -self.fromView.bounds.width*progress*1.25, y: 0)
                let transformAddScale = newTransform.scaledBy(x: max(0.9, 1.0-1*progress), y: max(0.9, 1.0-1*progress))
                
                self.fromView.transform = transformAddScale
                
                self.toView.transform = CGAffineTransform(scaleX: 0.1*progress+0.9, y: 0.1*progress+0.9)
                self.toView.layer.opacity = Float(progress)
            
            }
            
        case .failed:
            
            print("transitionFailed")
            
        default:
        
            //只支持左滑
            if swipeDirection != .swipeLeft {
                return
            }
            
            if swipeDirection == .swipeLeft || swipeDirection == .swipeRight {
                
                if isFinish {

                    fromView.removeGestureRecognizer(panGesture)
                    
                    let transformAddRoate = CGAffineTransform(rotationAngle: swipeDirection == .swipeRight ? CGFloat(M_PI_4/2) : CGFloat(-M_PI_4/2))
                    let newTransform = swipeDirection == .swipeRight ? transformAddRoate.translatedBy(x: self.fromView.bounds.height, y: 0) : transformAddRoate.translatedBy(x: -self.fromView.bounds.height, y: 0)
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        //缩放
                        if let scaleView = self.scaleView {
                            scaleView.transform = CGAffineTransform.init(scaleX: 0.9, y: 0.9)
                        }
                        
                        self.fromView.transform = newTransform
                        self.toView.transform = CGAffineTransform.identity
                        self.toView.layer.opacity = 1.0
                        
                    }, completion: { (success) in
                        
                        if let delegate = self.transitionDelegate {
                            delegate.didEndTransition(transition: self, isSuccess: true)
                        }
                        
                    })
                    
                }else{
                
                    UIView.animate(withDuration: 0.3, animations: {
                        self.fromView.transform = CGAffineTransform.identity
                        self.toView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                        self.toView.layer.opacity = 0.0
                    }, completion: { (success) in
                        
                        //更新ToView的状态
                        self.toView.transform = CGAffineTransform.identity
                        self.toView.layer.opacity = 1.0
                        
                        //缩放View
                        if let scaleView = self.scaleView {
                            
                            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [.curveEaseInOut], animations: {
                                scaleView.transform = CGAffineTransform.identity
                            }, completion: { (success) in
                            })
                        }
                        
                        //代理结束更新
                        if let delegate = self.transitionDelegate {
                            delegate.didEndTransition(transition: self, isSuccess: false)
                        }
                    })

                }
                
            }
            
            if swipeDirection == .swipeDown || swipeDirection == .swipeUp {
                //代理结束更新
                if let delegate = self.transitionDelegate {
                    delegate.didEndTransition(transition: self, isSuccess: isFinish)
                }

            }

            
        }
        
    }
    
    
    
}

