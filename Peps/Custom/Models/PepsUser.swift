//
//  PepsUser.swift
//
//
//  Created by Sivaprasad on 10/04/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import Foundation

public class PepsUser: NSObject, Codable {
    public var full_name: String? {
        return (first_name ?? "") + " " + (last_name ?? "")
    }

    public var last_name: String?
    public var first_name: String?
    public var email: String?
    public var user_id: String?
    public var date_of_birth: String?
    public var address: String?
    public var city: String?
    public var mobile_no: String?
    public var interests: [String]?
    public var gender: String?
    public var genderOther: String?
    public var image_url: String?
    public var is_worldwide_available: Bool?
    public var is_news_account_available: Int = 0
    public var is_content_account_available: Int = 0
    public var is_podcast_account_available: Int = 0
    public var worldwide_user_id: String?
    public var comments: NSMutableArray?
    public var podcast_account_name: String?
    public var content_account_name: String?
    public var news_site_name: String?
    public var selfie_id: String?
    public var front_id: String?
    public var back_id: String?
    public var name_public: Bool?

    public required init(from _: Decoder) throws {}

    public func encode(to _: Encoder) throws {}

    public class func modelsFromDictionaryArray(array: NSArray) -> [PepsUser] {
        var models: [PepsUser] = []
        for item in array {
            models.append(PepsUser(dictionary: item as! NSDictionary)!)
        }
        return models
    }

    public required init?(dictionary: NSDictionary) {
        email = dictionary[kEmail] as? String
        user_id = dictionary[kUser_Id] as? String
        date_of_birth = dictionary[kBirthDate] as? String
        first_name = dictionary[kFName] as? String
        last_name = dictionary[kLName] as? String
        address = dictionary["address"] as? String
        city = dictionary["city"] as? String
        mobile_no = dictionary["mobile_no"] as? String
        gender = dictionary[kGenderKey] as? String
        genderOther = dictionary[kGenderOtherKey] as? String
        interests = dictionary[kInterest] as? [String]
        image_url = dictionary["image_url"] as? String
        is_worldwide_available = (dictionary[kIsAuthenticateUser] as? Bool)
        worldwide_user_id = dictionary[kWorldwideUserId] as? String
        is_news_account_available = (dictionary["is_news_account_available"] as? Int) ?? 0
        is_content_account_available = (dictionary["is_content_account_available"] as? Int) ?? 0
        is_podcast_account_available = (dictionary["is_podcast_account_available"] as? Int) ?? 0
        selfie_id = dictionary["selfie_id"] as? String
        front_id = dictionary["front_id"] as? String
        back_id = dictionary["back_id"] as? String
        podcast_account_name = dictionary["podcast_account_name"] as? String
        content_account_name = dictionary["content_account_name"] as? String
        news_site_name = dictionary["news_site_name"] as? String
        name_public = dictionary["name_public"] as? Bool

        if let comments1 = dictionary["comments"] as? NSArray {
            comments = NSMutableArray(array: comments1)
        }
    }

    public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()
        dictionary.setValue(email, forKey: kEmail)
        dictionary.setValue(user_id, forKey: kUser_Id)
        dictionary.setValue(worldwide_user_id, forKey: kWorldwideUserId)
        dictionary.setValue(date_of_birth, forKey: kBirthDate)
        dictionary.setValue(address, forKey: "address")
        dictionary.setValue(city, forKey: "city")
        dictionary.setValue(last_name, forKey: kFName)
        dictionary.setValue(first_name, forKey: kLName)
        dictionary.setValue(mobile_no, forKey: "mobile_no")
        dictionary.setValue(gender, forKey: kGenderKey)
        dictionary.setValue(genderOther, forKey: kGenderOtherKey)
        dictionary.setValue(interests, forKey: kInterest)
        dictionary.setValue(image_url, forKey: "image_url")
        dictionary.setValue(is_worldwide_available, forKey: kIsAuthenticateUser)
        dictionary.setValue(comments, forKey: "comments")
        dictionary.setValue(is_content_account_available, forKey: "is_news_account_available")
        dictionary.setValue(is_content_account_available, forKey: "is_content_account_available")
        dictionary.setValue(is_content_account_available, forKey: "is_podcast_account_available")
        dictionary.setValue(selfie_id, forKey: "selfie_id")
        dictionary.setValue(front_id, forKey: "front_id")
        dictionary.setValue(back_id, forKey: "back_id")
        dictionary.setValue(podcast_account_name, forKey: "podcast_account_name")
        dictionary.setValue(content_account_name, forKey: "content_account_name")
        dictionary.setValue(news_site_name, forKey: "news_site_name")
        dictionary.setValue(name_public, forKey: "name_public")


        return dictionary
    }
}
