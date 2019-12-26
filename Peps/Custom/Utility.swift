//
//  Utility.swift
//  Peps
//
//  Created by KP Tech on 15/06/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import UIKit

class Utility: NSObject {}

class RoundImage: UIImageView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = frame.size.width / 2
        contentMode = .scaleToFill
    }
}
