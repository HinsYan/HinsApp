//
//  VideoMessageView.swift
//  FaceChat
//
//  Created by yantommy on 2019/1/27.
//  Copyright © 2019 yantommy. All rights reserved.
//

import UIKit

class VideoMessageView: UIView {

    @IBOutlet weak var btnAvatar: UIButton!
    @IBOutlet weak var lbeName: UILabel!
    @IBOutlet weak var lbeTime: UILabel!
    @IBOutlet weak var videoPreview: HinsVideoMessagePreView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnAvatar.layer.cornerRadius = btnAvatar.bounds.width/2
        btnAvatar.layer.masksToBounds = true
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}
