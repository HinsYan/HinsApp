//
//  BTNMessageCollCell.swift
//  FaceChat
//
//  Created by yantommy on 2019/1/21.
//  Copyright © 2019 yantommy. All rights reserved.
//

import UIKit

let kBTNMessageCollCellIdentifier = "kBTNMessageCollCellIdentifier"
class BTNMessageCollCell: UICollectionViewCell {
    
    
    var videoPreview: HinsVideoMessagePreView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initViews()
        
        // Initialization code
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 此处刷新后为正确的约束，在此修改UI相关
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.layoutIfNeeded()
    }
    func initViews(){
        videoPreview = HinsVideoMessagePreView(frame: self.bounds)
        videoPreview.frame = self.bounds
        addSubview(videoPreview)
    }
    
    deinit {
        print("销毁了cell")
    }
    
}
