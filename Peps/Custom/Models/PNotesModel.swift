//
//  PNotesModel.swift
//  Peps
//
//  Created by sivaprasad reddy on 02/07/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import Foundation

public class PNotesModel {
    public var age: Int?
    public var distance: Int?
    public var iAm: String?
    public var imageUrl: String?
    public var lookingFor: String?
    public var notes: String?
    public var notesFrom: String?
    public var respondWithPic: Bool?
    public var allowOther: Int?
    public var row_key: String?
    public var seeking: String?
    public var whocanseegender: String?
    public var whocanseeage: String?
    public var userKey: String?
    public var userLocation: NSDictionary?

    public class func modelsFromDictionaryArray(array: NSArray) -> [PNotesModel] {
        var models: [PNotesModel] = []
        for item in array {
            models.append(PNotesModel(dictionary: item as! NSDictionary)!)
        }
        return models
    }

    public required init?(dictionary: NSDictionary) {
        age = dictionary["age"] as? Int
        distance = dictionary["distance"] as? Int
        iAm = dictionary["iAm"] as? String
        row_key = dictionary["row_key"] as? String
        imageUrl = dictionary["imageUrl"] as? String
        lookingFor = dictionary["lookingFor"] as? String
        notes = dictionary["notes"] as? String
        notesFrom = dictionary["notesFrom"] as? String
        respondWithPic = dictionary["respondWithPic"] as? Bool
        allowOther = dictionary["allowOther"] as? Int
        seeking = dictionary["seeking"] as? String
        userLocation = dictionary["userLocation"] as? NSDictionary
        userKey = dictionary["userKey"] as? String
        whocanseegender = dictionary["whocanseegender"] as? String
        whocanseeage = dictionary["whocanseeage"] as? String
    }

    public func dictionaryRepresentation() -> NSDictionary {
        let dictionary = NSMutableDictionary()

        dictionary.setValue(age, forKey: "age")
        dictionary.setValue(distance, forKey: "distance")
        dictionary.setValue(iAm, forKey: "iAm")
        dictionary.setValue(row_key, forKey: "row_key")
        dictionary.setValue(imageUrl, forKey: "imageUrl")
        dictionary.setValue(lookingFor, forKey: "lookingFor")
        dictionary.setValue(notes, forKey: "notes")
        dictionary.setValue(notesFrom, forKey: "notesFrom")
        dictionary.setValue(respondWithPic, forKey: "respondWithPic")
        dictionary.setValue(allowOther, forKey: "allowOther")
        dictionary.setValue(seeking, forKey: "seeking")
        dictionary.setValue(userKey, forKey: "userKey")
        dictionary.setValue(userLocation, forKey: "userLocation")
        dictionary.setValue(whocanseeage, forKey: "whocanseeage")
        dictionary.setValue(whocanseegender, forKey: "whocanseegender")
        return dictionary
    }
}
