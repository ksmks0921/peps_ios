//
//  AuthData.swift
//  Peps
//
//  Created by KP Tech on 03/06/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import UIKit

class AuthData {
    public var back_id: String?
    public var date_of_birth: String?
    public var front_id: String?
    public var last_name: String?
    public var first_name: String?
    public var selfie_id: String?
    public var worldwide_user_id: String?
    public var comments: [PComments]?

    public required init?(dictionary: NSDictionary) {
        back_id = dictionary["back_id"] as? String
        date_of_birth = dictionary["date_of_birth"] as? String
        front_id = dictionary["front_id"] as? String
        first_name = dictionary[kFName] as? String
        last_name = dictionary[kLName] as? String
        selfie_id = dictionary["selfie_id"] as? String
        worldwide_user_id = dictionary[kWorldwideUserId] as? String
        if let comments1 = dictionary["comments"] as? NSDictionary {
            comments = PComments.modelsFromDictionaryArray(array: comments1.allValues as NSArray)
        }
    }

    public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(back_id, forKey: "back_id")
        dictionary.setValue(date_of_birth, forKey: "date_of_birth")
        dictionary.setValue(front_id, forKey: "front_id")
        dictionary.setValue(first_name, forKey: "first_name")
        dictionary.setValue(last_name, forKey: "last_name")
        dictionary.setValue(selfie_id, forKey: "selfie_id")
        dictionary.setValue(worldwide_user_id, forKey: kWorldwideUserId)
        return dictionary
    }
}
