//
//  PComments.swift
//  Peps
//
//  Created by Shubham Garg on 14/05/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import Foundation

public class PComments {
    public var row_key: String?
    public var email: String?
    public var comment_text: String?
    public var created_at: Int?
    public var profile_url: String?
    public var user_id: String?
    public var user_name: String?
    public var offensive_content: String?

    public class func modelsFromDictionaryArray(array: NSArray) -> [PComments] {
        var models: [PComments] = []
        for item in array {
            let comment = PComments(dictionary: item as! NSDictionary)!
            if let commentEmail = comment.email?.stringKey(),
            PWebService.sharedWebService.myBlockedUsers.contains(commentEmail) {
                
            } else {
                if let _ = comment.offensive_content {
                    
                } else {
                    models.append(comment)
                }
            }
        }
        return models
    }

    public required init?(dictionary: NSDictionary) {
        row_key = dictionary["row_key"] as? String
        comment_text = dictionary["comment_text"] as? String
        email = dictionary[kEmail] as? String
        created_at = dictionary["created_at"] as? Int
        profile_url = dictionary["profile_url"] as? String
        user_id = dictionary["user_id"] as? String
        user_name = dictionary["user_name"] as? String
        offensive_content = dictionary["offensive_content"] as? String
    }

    public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()

        dictionary.setValue(row_key, forKey: "row_key")
        dictionary.setValue(comment_text, forKey: "comment_text")
        dictionary.setValue(email, forKey: kEmail)
        dictionary.setValue(created_at, forKey: "created_at")
        dictionary.setValue(profile_url, forKey: "profile_url")
        dictionary.setValue(user_id, forKey: kUser_Id)
        dictionary.setValue(user_name, forKey: "user_name")
        dictionary.setValue(offensive_content, forKey: "offensive_content")
        return dictionary
    }
}
