//
//  BTNViewExtension.swift
//  BetterNet
//
//  Created by yantommy on 2016/12/29.
//  Copyright © 2016年 yantommy. All rights reserved.
//

import UIKit

class BTNViewExtension: NSObject {

}
// MARK: - UIView
extension UIView {

    
    
    // MARK: - 圆角
    func addCornerMask(rectCorners: UIRectCorner, cornerRadii: CGFloat){
    
        let size = CGSize(width: cornerRadii, height: cornerRadii)
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: rectCorners, cornerRadii: size)
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
        
    }
    
    // MARK: - 阴影
    func addShadowWith(color: UIColor, opacity: Float? , radius: CGFloat?, offset: CGSize?){
        
        layer.shadowColor = color.cgColor
        
        if let shadowOpacity = opacity {
            layer.shadowOpacity = shadowOpacity
        }else{
            layer.shadowOpacity = 0.5
        }
        
        
        if let shadowRadius = radius {
            layer.shadowRadius = shadowRadius
        }else{
            layer.shadowRadius = 5
        }
        
        
        if let shadowOffset = offset {
            layer.shadowOffset = shadowOffset
        }else{
            layer.shadowOffset = CGSize(width: 0, height: 3)
        }
    }

}

// MARK: - UINavigationBar
extension UINavigationBar {
    
//    func hideBottomHairline() {
//        let navigationBarImageView = hairlineImageViewInNavigationBar(view: self)
//        navigationBarImageView!.isHidden = true
//    }
//    
//    func showBottomHairline() {
//        let navigationBarImageView = hairlineImageViewInNavigationBar(view: self)
//        navigationBarImageView!.isHidden = false
//    }
//    
//    private func hairlineImageViewInNavigationBar(view: UIView) -> UIImageView? {
//        if view is UIImageView && view.bounds.height <= 1.0 {
//            return (view as! UIImageView)
//        }
//        
//        let subviews = (view.subviews as [UIView])
//        for subview: UIView in subviews {
//            if let imageView: UIImageView = hairlineImageViewInNavigationBar(view: subview) {
//                return imageView
//            }
//        }
//
//        return nil
//    }
    
}
