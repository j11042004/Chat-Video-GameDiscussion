//
//  PlaylistsTableViewCell.swift
//  Chat&VideoForGameDiscussion
//
//  Created by Uran on 2017/9/11.
//  Copyright © 2017年 Uran. All rights reserved.
//

import UIKit

class PlaylistsTableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnailImgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
