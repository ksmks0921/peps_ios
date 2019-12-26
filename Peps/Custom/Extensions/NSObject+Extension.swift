//
//  NSObject+Extension.swift
//  Peps
//
//  Created by Shubham Garg on 15/05/19.
//  Copyright © 2019 SHUBHAM GARG. All rights reserved.
//

import Foundation

extension NSObject {
    // get class name
    class var identifier: String {
        return String(describing: self)
    }
}
