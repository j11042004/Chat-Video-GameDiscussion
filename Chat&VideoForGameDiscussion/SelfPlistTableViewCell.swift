//
//  SelfPlistTableViewCell.swift
//  Chat&VideoForGameDiscussion
//
//  Created by Uran on 2017/8/24.
//  Copyright © 2017年 Uran. All rights reserved.
//

import UIKit

class SelfPlistTableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnailImgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
