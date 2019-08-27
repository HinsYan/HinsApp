//
//  BTNInviteTableCell.swift
//  FaceChat
//
//  Created by yantommy on 2019/1/31.
//  Copyright © 2019 yantommy. All rights reserved.
//

import UIKit

let kBTNInviteTableCellIdentifier = "kBTNInviteTableCellIdentifier"
class BTNInviteTableCell: UITableViewCell {

    @IBOutlet weak var infoLbe: UILabel!
    @IBOutlet weak var icon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        initViews()
        
        // Initialization code
    }
    
    func initViews() {
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
