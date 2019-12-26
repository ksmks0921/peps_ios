//
//  PrimaryButton.swift
//  Peps
//
//  Created by KP Tech on 14/04/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import UIKit

class PrimaryButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = SecondaryCgColor
    }
}

class SecondaryButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderColor = SecondaryCgColor.cgColor
        layer.borderWidth = 1.0
        self.setTitleColor(SecondaryCgColor, for: .normal)
    }
}

class ShadowView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = false
        layer.shadowRadius = 1
        layer.shadowOpacity = 0.5
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
    }
}
