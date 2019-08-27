//
//  BTNSettingTableCellTableViewCell.swift
//  Chatter
//
//  Created by yantommy on 2017/1/1.
//  Copyright © 2017年 BetterNet. All rights reserved.
//

import UIKit

let kBTNSettingTableCellIdentifier = "kBTNSettingTableCellIdentifier"
class BTNSettingTableCell: UITableViewCell {

    @IBOutlet weak var lbeTitle: UILabel!
    @IBOutlet weak var lbeDetail: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imgIcon: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
