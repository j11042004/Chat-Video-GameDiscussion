//
//  MessageTableViewCell.swift
//  SockitIOTest
//
//  Created by Uran on 2017/8/10.
//  Copyright © 2017年 Uran. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

   
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var message: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
