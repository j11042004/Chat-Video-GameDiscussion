//
//  ImageTableViewCell.swift
//  SockitIOTest
//
//  Created by Uran on 2017/8/11.
//  Copyright © 2017年 Uran. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var msgImage: UIImageView!
    var origoBase64 = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
