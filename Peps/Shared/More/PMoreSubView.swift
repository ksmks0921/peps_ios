//
//  PMoreSubView.swift
//  Peps
//
//  Created by YER on 08/06/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import UIKit
protocol MoretDelegate {
    func logOutBtnAction(logout: UIButton)
}

class PMoreSubView: UITableViewHeaderFooterView {
    var delegate: MoretDelegate?

    @IBAction func logoutAction(_ sender: UIButton) {
        delegate?.logOutBtnAction(logout: sender)
    }
}
