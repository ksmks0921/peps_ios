//
//  PAuthTableViewCell.swift
//  PepsAdmin
//
//  Created by Shubham Garg on 28/05/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import UIKit

class PAuthTableViewCell: UITableViewCell {
    @IBOutlet var worldwideIdLbl: UILabel!
    @IBOutlet var nameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
