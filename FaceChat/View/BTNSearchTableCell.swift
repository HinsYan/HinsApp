//
//  BTNSearchTableCell.swift
//  FaceChat
//
//  Created by yantommy on 2019/1/31.
//  Copyright © 2019 yantommy. All rights reserved.
//

import UIKit

let kBTNSearchTableCellIdentifier = "kBTNSearchTableCellIdentifier"
class BTNSearchTableCell: UITableViewCell {

   
    @IBOutlet weak var numberTF: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        initViews()
        
        // Initialization code
    }
    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
    
    func initViews() {
        
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
