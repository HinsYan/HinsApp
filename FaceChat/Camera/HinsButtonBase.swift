//
//  HinsButtonBase.swift
//  HinsButton
//
//  Created by yantommy on 2017/2/26.
//  Copyright © 2017年 BetterNet. All rights reserved.
//

import UIKit

class HinsButtonBase: UIButton {

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addTarget(self, action: #selector(self.actionPlayUISound), for: .touchUpInside)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.addTarget(self, action: #selector(self.actionPlayUISound), for: .touchUpInside)

    }


    
    @objc func actionPlayUISound() {
        HinsUISoundManager.playUISound(type: .success)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesBegan(touches, with: event)
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 10, options: .curveEaseOut, animations: {
            
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            
        }, completion: nil)
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesEnded(touches, with: event)
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 10, options: .curveEaseOut, animations: {
            
            self.transform = CGAffineTransform.identity
            
        }, completion: nil)
        
    }

}
