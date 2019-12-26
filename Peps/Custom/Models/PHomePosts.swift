//
//  PHomePosts.swift
//  Peps
//
//
//  Created by Shubham Garg on 14/05/19.
//  Copyright © 2019 KP Tech. All rights reserved.

import Foundation

public class PHomePosts {
    public var email: String?
    public var description: String?
    public var user_full_name: String?
    public var interests: [String]?
    public var row_Key: String?
    public var user_image_url: String?
    public var source_path: String?
    public var created_at: Int?
    public var comments: NSMutableArray?
    public var likes: NSArray?
    public var url: String?
    public var post_type: String?
    public var source_type: String?
    public var is_adult_content: Bool?
    public var thumb_path: String?

    public class func modelsFromDictionaryArray(array: NSArray) -> [PHomePosts] {
        var models: [PHomePosts] = []
        for item in array {
            models.append(PHomePosts(dictionary: item as! NSDictionary)!)
        }
        return models
    }

    public required init?(dictionary: NSDictionary) {
        email = dictionary[kEmailKey] as? String
        post_type = dictionary["post_type"] as? String
        interests = dictionary["interests"] as? [String]
        row_Key = dictionary["row_key"] as? String
        user_image_url = dictionary["user_image_url"] as? String
        source_path = dictionary["source_path"] as? String
        source_type = dictionary["source_type"] as? String
        description = dictionary["description"] as? String
        user_full_name = dictionary["user_full_name"] as? String
        created_at = dictionary["created_at"] as? Int
        if let comments1 = dictionary["comments"] as? NSArray {
            comments = NSMutableArray(array: comments1)
        }
        likes = dictionary["likes"] as? NSArray
        is_adult_content = dictionary["is_adult_content"] as? Bool
        url = dictionary["url"] as? String
        thumb_path = dictionary["thumb_path"] as? String
    }

    public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()

        dictionary.setValue(email, forKey: kEmailKey)
        dictionary.setValue(post_type, forKey: "post_type")
        dictionary.setValue(interests, forKey: "interests")
        dictionary.setValue(user_image_url, forKey: "user_image_url")
        dictionary.setValue(source_path, forKey: "source_path")
        dictionary.setValue(source_type, forKey: "source_type")
        dictionary.setValue(description, forKey: "description")
        dictionary.setValue(user_full_name, forKey: "user_full_name")
        dictionary.setValue(created_at, forKey: "created_at")
        dictionary.setValue(row_Key, forKey: "row_key")
        dictionary.setValue(comments, forKey: "comments")
        dictionary.setValue(likes, forKey: "likes")
        dictionary.setValue(is_adult_content, forKey: "is_adult_content")
        dictionary.setValue(url, forKey: "url")
        dictionary.setValue(thumb_path, forKey: "thumb_path")
        return dictionary
    }
}
