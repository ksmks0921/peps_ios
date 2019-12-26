//
//  PCellModel.swift
//  Peps
//
//  Created by KP Tech on 04/06/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import UIKit

class PCellModel {
    public var key = ""
    public var type = ""
    public var title = ""
    public var value: Any = ""

    public required init(dictionary: NSDictionary) {
        key = dictionary["key"] as! String
        title = dictionary["title"] as! String
        type = dictionary["type"] as! String
        if let v = dictionary["value"] {
            value = v
        }
    }

    public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(key, forKey: "key")
        dictionary.setValue(type, forKey: "type")
        dictionary.setValue(title, forKey: "title")
        dictionary.setValue(value, forKey: "value")
        return dictionary
    }
}
