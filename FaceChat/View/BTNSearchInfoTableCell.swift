//
//  BTNSearchInfoCell.swift
//  FaceChat
//
//  Created by yantommy on 2019/1/31.
//  Copyright © 2019 yantommy. All rights reserved.
//

import UIKit

let kBTNSearchInfoTableCellIdentifier = "kBTNSearchInfoTableCellIdentifier"
class BTNSearchInfoTableCell: UITableViewCell {

    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLbe: UILabel!
    @IBOutlet weak var infoLbe: UILabel!
    
    
    @IBOutlet weak var lbeAdd: UILabel!
    @IBOutlet weak var lbeNameIcon: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        initViews()
    }
    
    func initViews() {
        lbeAdd.layer.cornerRadius = lbeAdd.bounds.height/2
        lbeAdd.layer.masksToBounds = true
        lbeNameIcon.text = ""
        avatarView.layer.cornerRadius = 6.0
        avatarView.layer.masksToBounds = true
    }

    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.sd_setImage(with: nil, completed: nil)
        nameLbe.text = ""
        infoLbe.text = ""
        lbeNameIcon.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
