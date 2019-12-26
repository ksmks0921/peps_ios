//
//  PWebService.swift
//
//
//  Created by KP Tech on 20/10/17.
//  Copyright © 2017 KP Tech. All rights reserved.
//

import Firebase
import FirebaseDatabase
import FirebaseStorage
import UIKit

enum APIType: String {
    case signUpAccount = "SIGN_UP"
    case signInAccount = "SIGN_IN"
    case forgotPassowrdAnAccount = "FORGOT_PASSWORD"
    case updateProfile = "UPDATE_PROFILE"
    case authUpdateProfile = "AUTH_UPDATE_PROFILE"
    case updatePassowrdAnAccount = "UPDATE_PASSWORD"
    case contsctUS = "CONTACT_US"
    case status = "STATUS"
}

let kUSERS_T = "USERS"
let kWORLDWIDE_REQUEST_LIST_T = "WORLDWIDE_REQUESTS"
let kSPECIAL_ACCOUNT_REQUESTS = "SPECIAL_ACCOUNT_REQUESTS"

let kPOSTS_LIST_T = "POSTS_LISTS"
let kUSER_NOTES_T = "USERNOTES"

let kREPORT_USER = "REPORT_USER"
let kBLOCK_USER = "BLOCK_USER"
let kBLOCKED_BY_ADMIN_T = "BLOCKED_BY_ADMIN"
let kReportedByUsers = "reported_by_users"

class PWebService {
    let kPushKey = "key=AAAAAm8psKo:APA91bGgUF4x5SfVWtav1NwcrKoxRcLhL0nS54yN_gwoVJ5htY5YpuvcywcLnO_deN_u6hmoCTDOuZz2ukTq1efjSzXQM7iznxzEx3awG59R3o8oH9_wnHpdJaCr9iSJksBGPuSEh99U"

    let kFirebaseServerValueTimestamp = [".sv": "timestamp"]
    var userKey = ""
    var myBlockedUsers = [String]()
    var currentUser = PepsUser(dictionary: [String: AnyObject]() as NSDictionary)
    static let sharedWebService = PWebService()

    typealias CompletionHandler = (_ status: Int, _ response: [String: AnyObject]?, _ message: String?) -> Void

    typealias CompletionHandlerWithAnyObject = (_ status: Int, _ response: AnyObject?, _ message: String?) -> Void

    fileprivate let ref = Database.database().reference()

    func webService(apiType: APIType, parameters: [String: AnyObject], completion: @escaping CompletionHandler) {
        if apiType.rawValue == APIType.signInAccount.rawValue {
            signInAccount(parameters: parameters, completion: completion)
        } else if apiType.rawValue == APIType.forgotPassowrdAnAccount.rawValue {
            forgotPasswordAccount(parameters: parameters, completion: completion)
        } else if apiType.rawValue == APIType.updateProfile.rawValue {
            updateProfile(parameters: parameters, completion: completion)
        } else if apiType.rawValue == APIType.authUpdateProfile.rawValue {
            authRequest(parameters: parameters, completion: completion)
        } else if apiType.rawValue == APIType.signUpAccount.rawValue {
            createAnAccount(parameters: parameters, completion: completion)
        }
    }

    func goOffline() {
        let presenceRef = Database.database().reference(withPath: "disconnectmessage")
        presenceRef.onDisconnectSetValue("I disconnected!")
    }

    func createAnAccount(parameters: [String: AnyObject], completion: @escaping CompletionHandler) {
        let childName = kUSERS_T
        let userEmail = parameters[kEmailKey] as! String
        let userKey = userEmail.stringKey()

        if APP_DELEGATE.fbUser != nil {
            var parametersTemp = parameters
            // parametersTemp.removeValue(forKey: kPasswordKey)
            parametersTemp.removeValue(forKey: kConfirmPasswordKey)
            // parametersTemp[kUserStatus] = 0 as AnyObject
            let dataDic = postRecord(childName: childName, newEntryKey: userKey, parameters: parametersTemp)
            currentUser = PepsUser(dictionary: dataDic as NSDictionary)
            saveUser(user: currentUser)
            _ = postRecord(childName: kUSERS_T, newEntryKey: userKey, parameters: parameters)
            completion(100, dataDic, "Account created successfully.")
        } else {
            Auth.auth().createUser(withEmail: parameters[kEmailKey] as! String, password: parameters[kPasswordKey] as! String) { _, error in

                if error == nil {
                    var parametersTemp = parameters
                    parametersTemp.removeValue(forKey: kPasswordKey)
                    parametersTemp.removeValue(forKey: kConfirmPasswordKey)
                    parametersTemp[kUserStatus] = 0 as AnyObject

                    self.currentUser = PepsUser(dictionary: parametersTemp as NSDictionary)
                    self.saveUser(user: self.currentUser)
                    let dataDic = self.postRecord(childName: childName, newEntryKey: userKey, parameters: parametersTemp)

                    _ = self.postRecord(childName: kUSERS_T, newEntryKey: userKey, parameters: parameters)
                    completion(100, dataDic, "Account created successfully.")
                } else {
                    completion(101, nil, error?.localizedDescription)
                }
            }
        }
    }

    internal func getUserDetail(key: String, completion: @escaping CompletionHandlerWithAnyObject) {
        let childName = kUSERS_T

        ref.child(childName).child(key).observeSingleEvent(of: .value, with: { snapshot in
            if let userDic = snapshot.value as? [String: AnyObject] {
                let user = PepsUser(dictionary: userDic as NSDictionary)
                completion(200, user, "get user")
            } else {
                completion(100, nil, "NO user found")
            }

        })
    }

    internal func signInAccount(parameters: [String: AnyObject], completion: @escaping CompletionHandler) {
        let email = parameters[kEmailKey]! as! String

        Auth.auth().signIn(withEmail: email.lowercased(), password: parameters[kPasswordKey]! as! String) { _, error in

            if error == nil {
                let userKey = email.stringKey()
                let childName = kUSERS_T
                self.userKey = userKey
                self.ref.child(childName).child(userKey).observeSingleEvent(of: .value, with: { snapshot in

                    if let userDic = snapshot.value as? [String: AnyObject] {
                        self.currentUser = PepsUser(dictionary: userDic as NSDictionary)
                        self.saveUser(user: self.currentUser)
                    }
                    self.loadMyBlockedUsers()
                    completion(100, snapshot.value as? [String: AnyObject], "Logged in successfully")
                })
            } else {
                completion(101, nil, error?.localizedDescription)
            }
        }
    }

    internal func autoLogin(completion: @escaping CompletionHandler) {
        Auth.auth().addStateDidChangeListener { _, user in
            let userDefaults = UserDefaults.standard
            let decoded = userDefaults.data(forKey: "CurrentUser")
            if (try? JSONDecoder().decode(PepsUser.self, from: decoded ?? Data())) != nil {
            if user != nil {
                if user?.email != nil {
                    let userKey = user?.email?.stringKey()
                    let childName = kUSERS_T
                    self.userKey = userKey!
                    self.loadMyBlockedUsers()
                    self.ref.child(childName).child(userKey!).observeSingleEvent(of: .value, with: { snapshot in
                        if let userDic = snapshot.value as? [String: AnyObject] {
                            self.currentUser = PepsUser(dictionary: userDic as NSDictionary)
                            self.saveUser(user: self.currentUser)
                        }
                        completion(100, snapshot.value as? [String: AnyObject], "Logged in Successfully")
                    })
                }
            }
            else {
                completion(101, nil, "Login failed.")
            }
                
            }
        }
    }

    internal func forgotPasswordAccount(parameters: [String: AnyObject], completion: @escaping CompletionHandler) {
        let email = parameters[kEmailKey]! as! String

        Auth.auth().sendPasswordReset(withEmail: email, completion: { error in

            if error == nil {
                completion(100, nil, "Password reset email sent successfully.")

            } else {
                completion(101, nil, error?.localizedDescription)
            }
        })
    }

    internal func getStatus(userId: String, completion: @escaping CompletionHandler) {
        let childName = kUSERS_T
        let userKey = userId
        ref.child(childName).child(userKey).child("connections").observeSingleEvent(of: .value, with: { snapshot in

            completion(100, snapshot.value as? [String: AnyObject], "Data")
        })
    }

    internal func authRequest(parameters: [String: AnyObject], completion: @escaping CompletionHandler) {
        let childName = kWORLDWIDE_REQUEST_LIST_T
        let userKey = currentUser?.email?.stringKey()
        ref.child(childName).child(userKey!).updateChildValues(parameters)
        completion(100, nil, "Profile updated Successfully.")
    }

    internal func newsAccountRequest(requestType: String, parameters: [String: AnyObject], completion: @escaping CompletionHandler) {
        let itemKeyRef = ref.childByAutoId()
        let itemKey = itemKeyRef.key

        ref.child(kSPECIAL_ACCOUNT_REQUESTS).child(itemKey!).updateChildValues(parameters)

        if requestType == "newsAccount" {
            ref.child(kUSERS_T).child(userKey).child("is_news_account_available").setValue(1)
        } else if requestType == "contentAccount" {
            ref.child(kUSERS_T).child(userKey).child("is_content_account_available").setValue(1)
        } else if requestType == "podcastAccount" {
            ref.child(kUSERS_T).child(userKey).child("is_podcast_account_available").setValue(1)
        }

        completion(100, nil, "News Account Request Successfully.")
    }

    internal func newsAccountRequestApprove(requestType: String,
                                            email: String,
                                            rowKey: String,
                                            contentAccountName: String?,
                                            podcastAccountName: String?,
                                            newSiteName: String?,
                                            completion: @escaping CompletionHandler) {
        ref.child(kSPECIAL_ACCOUNT_REQUESTS).child(rowKey).updateChildValues([kStatus: 1])
        let myUserKey = email.stringKey()
        if requestType == "newsAccount" {
            ref.child(kUSERS_T).child(myUserKey).child("is_news_account_available").setValue(2)
            ref.child(kUSERS_T).child(myUserKey).child("news_site_name").setValue(newSiteName!)
        } else if requestType == "contentAccount" {
            ref.child(kUSERS_T).child(myUserKey).child("is_content_account_available").setValue(2)
            ref.child(kUSERS_T).child(myUserKey).child("content_account_name").setValue(contentAccountName!)
        } else if requestType == "podcastAccount" {
            ref.child(kUSERS_T).child(myUserKey).child("is_podcast_account_available").setValue(2)
            ref.child(kUSERS_T).child(myUserKey).child("podcast_account_name").setValue(podcastAccountName!)
        }
        completion(100, nil, "News Account Request Successfully.")
    }

    internal func updateProfile(parameters: [String: AnyObject], completion: @escaping CompletionHandler) {
        let childName = kUSERS_T
        let userKey = currentUser?.email?.stringKey()
        ref.child(childName).child(userKey!).updateChildValues(parameters)

        ref.child(kUSERS_T).child(userKey!).observeSingleEvent(of: .value, with: { snapshot in
            if let userDic = snapshot.value as? [String: AnyObject] {
                self.currentUser = PepsUser(dictionary: userDic as NSDictionary)
                self.saveUser(user: self.currentUser)
            }
            completion(100, snapshot.value as? [String: AnyObject], "Profile updated Successfully.")
        })
    }

    internal func createFeed(parameters: [String: AnyObject], completion: @escaping CompletionHandler) {
        let itemKeyRef = ref.childByAutoId()
        let itemKey = itemKeyRef.key

        var p = parameters
        p["updated_at"] = [".sv": "timestamp"] as AnyObject
        p["created_at"] = [".sv": "timestamp"] as AnyObject
        p["row_key"] = itemKey! as AnyObject

        ref.child(kPOSTS_LIST_T).child(itemKey!).setValue(p)
        completion(100, nil, "Posted Successfully.")
    }

    func fetchRecord(childName: String,
                     queryChildName: String? = nil,
                     queryValue: AnyObject? = nil,
                     equalToFilterArr: [String: AnyObject]? = nil,
                     notEqualToFilterArr _: [String: String]? = nil,
                     completion: @escaping CompletionHandlerWithAnyObject) {
        if queryChildName == nil {
            ref
                .child(childName)
                .observeSingleEvent(of: .value, with: { snapshot in
                    self.parsedFetchedData(childName: childName, snapshot: snapshot, completion: completion, equalToFilterArr: equalToFilterArr)
                })
        } else {
            ref
                .child(childName)
                .queryOrdered(byChild: queryChildName!)
                .queryEqual(toValue: queryValue)
                .observeSingleEvent(of: .value, with: { snapshot in

                    self.parsedFetchedData(childName: childName, snapshot: snapshot, completion: completion, equalToFilterArr: equalToFilterArr)
                })
        }
    }
    

    func parsedFetchedData(childName: String, snapshot: DataSnapshot, completion: @escaping CompletionHandlerWithAnyObject, equalToFilterArr: [String: AnyObject]? = nil) {
        var alArr = [[String: AnyObject]]()
        for al in snapshot.children {
            let key = (al as! DataSnapshot).key

            if ((al as! DataSnapshot).value as? [String: AnyObject]) == nil {
                break
            }
            var data = (al as! DataSnapshot).value as! [String: AnyObject]

            data["row_key"] = key as AnyObject
            if childName == kPOSTS_LIST_T {
                if let commentsDic = data["comments"] as? [String: AnyObject] {
                    let commentArr = Array(commentsDic.values)
                    data["comments"] = commentArr as AnyObject
                }

                if let likesDic = data["likes"] as? [String: AnyObject] {
                    let likeArr = Array(likesDic.values)
                    data["likes"] = likeArr as AnyObject
                }
            }
            if let netfarray = equalToFilterArr {
                for (key, value) in netfarray {
                    if let value1 = data[key] as? String, let value = value as? String {
                        if value1 == value {
                            alArr.append(data)
                        }
                    } else {
                        alArr.append(data)
                    }
                }
            } else {
                alArr.append(data)
            }
        }

        alArr.sort { (object1, object2) -> Bool in

            let o1 = object1["created_at"] as? Double
            let o2 = object2["created_at"] as? Double

            if o1 != nil && o2 != nil {
                if o1! < o2! {
                    return true

                } else {
                    return false
                }
            } else {
                return false
            }
        }

        completion(100, alArr as AnyObject, "Data")
    }

    func addComments(parameters: [String: AnyObject], rowKey: String, childName: String, receiverEmail _: String, completion: @escaping CompletionHandler) {
        let commentKeyRef = ref.childByAutoId()
        let commentKey = commentKeyRef.key
        var p = parameters
        p["updated_at"] = [".sv": "timestamp"] as AnyObject
        p["created_at"] = [".sv": "timestamp"] as AnyObject
        p["row_key"] = commentKey as AnyObject
        ref.child(childName).child(rowKey).child("comments").child(commentKey!).setValue(p)

        ref.child(childName).child(rowKey).observeSingleEvent(of: .value, with: { snapshot in

            completion(100, snapshot.value as? [String: AnyObject], "Added Successfully.")
        })
    }

    func addCommentAuth(parameters: [String: AnyObject],
                        receiverEmail: String,
                        completion: @escaping CompletionHandler) {
        let commentKeyRef = ref.childByAutoId()
        let commentKey = commentKeyRef.key
        var p = parameters
        p["updated_at"] = [".sv": "timestamp"] as AnyObject
        p["created_at"] = [".sv": "timestamp"] as AnyObject
        p["row_key"] = commentKey as AnyObject
        let userKey = receiverEmail.stringKey()
        ref.child(kWORLDWIDE_REQUEST_LIST_T).child(userKey).child("comments").child(commentKey!).setValue(p)
        completion(100, nil, "Added Successfully.")
    }
    
    func updateNotesUser(notesRowKey: String, parameters: [String: AnyObject], completion: @escaping CompletionHandler) {
        let childName = kUSER_NOTES_T
        let userKey = currentUser?.email?.stringKey()
        ref.child(childName).child(notesRowKey).child("notes_users").child(userKey!).updateChildValues(parameters)
        completion(100, nil, "Profile updated Successfully.")
    }
    
    func addNotesComment(parameters: [String: AnyObject], notesRowKey: String,
                        userKey: String,
                        completion: @escaping CompletionHandler) {
        let commentKeyRef = ref.childByAutoId()
        let commentKey = commentKeyRef.key
        var p = parameters
        p["updated_at"] = [".sv": "timestamp"] as AnyObject
        p["created_at"] = [".sv": "timestamp"] as AnyObject
        p["row_key"] = commentKey as AnyObject
        ref.child(kUSER_NOTES_T).child(notesRowKey).child("notes_users").child(userKey).child("comments").child(commentKey!).setValue(p)
        completion(100, nil, "Added Successfully.")
    }

    func addlike(parameters: [String: AnyObject], rowKey: String, childName: String, receiverEmail _: String, completion: @escaping CompletionHandler) {
        var p = parameters
        p["updated_at"] = [".sv": "timestamp"] as AnyObject
        p["created_at"] = [".sv": "timestamp"] as AnyObject
        p["row_key"] = (currentUser?.email?.stringKey() ?? "") as AnyObject
        ref.child(childName).child(rowKey).child("likes").child(currentUser?.email?.stringKey() ?? "").setValue(p)

        ref.child(childName).child(rowKey).observeSingleEvent(of: .value, with: { snapshot in

            completion(100, snapshot.value as? [String: AnyObject], "Added Successfully.")
        })
    }

    func postRecord(childName: String, newEntryKey: String, parameters: [String: AnyObject]) -> [String: AnyObject] {
        var p = parameters
        p["updated_at"] = [".sv": "timestamp"] as AnyObject
        p["created_at"] = [".sv": "timestamp"] as AnyObject

        ref.child(childName).child(newEntryKey).setValue(p)

        return p
    }

    internal func createNewTable(apiType: String, parameters: [String: AnyObject], completion: @escaping CompletionHandler) {
        let itemKeyRef = ref.childByAutoId()
        let itemKey = itemKeyRef.key

        var p = parameters
        p["updated_at"] = [".sv": "timestamp"] as AnyObject
        p["created_at"] = [".sv": "timestamp"] as AnyObject

        ref.child(apiType).child(itemKey!).setValue(p)
        completion(100, nil, "Posted Successfully.")
    }

    func updatePost(parameters: [String: AnyObject], rowKey: String, childName: String, completion: @escaping CompletionHandler) {
        ref.child(childName).child(rowKey).updateChildValues(parameters)
        completion(100, nil, "Your Post Updated Successfully.")
    }

    func removePost(rowKey: String, childName: String, completion: @escaping CompletionHandler) {
        ref.child(childName).child(rowKey).removeValue { error, _ in
            if error == nil {
                completion(100, nil, "Post removed successfully.")
            }
        }
    }

    func uploadImage(image: UIImage, imageName: String, folderNamePath: String, completion: @escaping CompletionHandlerWithAnyObject) {
        let storage = Storage.storage()
        let storageRef = storage.reference()

        let data1 = image.jpegData(compressionQuality: 0.8)

        let riversRef = storageRef.child("\(folderNamePath)/\(imageName).png")

        _ = riversRef.putData(data1!, metadata: nil) { metadata, error in
            guard metadata != nil else {
                completion(101, error as AnyObject, error?.localizedDescription)
                return
            }
            riversRef.downloadURL { url, _ in
                completion(100, url as AnyObject, "Groups")
            }
        }
    }

    func uploadVideo(data: Data, videoName: String, folderNamePath: String, completion: @escaping CompletionHandlerWithAnyObject) {
        let storage = Storage.storage()
        let storageRef = storage.reference()

        let riversRef = storageRef.child("\(folderNamePath)/\(videoName).mp4")

        _ = riversRef.putData(data, metadata: nil) { metadata, error in
            guard metadata != nil else {
                completion(101, error as AnyObject, error?.localizedDescription)
                return
            }
            riversRef.downloadURL { url, _ in
                completion(100, url as AnyObject, "Groups")
            }
        }
    }

    private func saveUser(user: PepsUser?) {
        let userDefaults = UserDefaults.standard
        let data = try? JSONEncoder().encode(user)
        userDefaults.set(data, forKey: "CurrentUser")
        userDefaults.synchronize()
    }

    func deleteComment(tableKey: String, postKey: String, comment: PComments, completion: @escaping CompletionHandler) {
        if let commentKey = comment.row_key {
            ref.child(tableKey).child(postKey).child("comments").child(commentKey).removeValue { _, _ in
                completion(100, nil, nil)
            }
        }
    }

    internal func authenticateUser(parameters: [String: AnyObject], userKey: String, completion: @escaping CompletionHandler) {
        ref.child(kWORLDWIDE_REQUEST_LIST_T).child(userKey).updateChildValues(["status": "1"])

        let childName = kUSERS_T
        var finalParameters = parameters
        finalParameters[kIsAuthenticateUser] = true as AnyObject
        ref.child(childName).child(userKey).updateChildValues(finalParameters)
        ref.child(kUSERS_T).child(userKey).observeSingleEvent(of: .value, with: { snapshot in
            if let userDic = snapshot.value as? [String: AnyObject] {
                self.currentUser = PepsUser(dictionary: userDic as NSDictionary)
                self.saveUser(user: self.currentUser)
            }
            completion(100, snapshot.value as? [String: AnyObject], "Profile updated Successfully.")
        })
    }

    func fetchAuthData(userKey: String, completion: @escaping CompletionHandlerWithAnyObject) {
        ref.child(kWORLDWIDE_REQUEST_LIST_T).child(userKey).observeSingleEvent(of: .value, with: { snapshot in
            if let authDic = snapshot.value as? [String: AnyObject] {
                completion(100, authDic as AnyObject, "Data Fetch Successfully")
            } else {
                completion(101, nil, "Data Fetch in Failed")
            }
        })
    }
    
    func fetchNotesCommentForCreater(notesRowKey: String, completion: @escaping CompletionHandlerWithAnyObject) {
        ref.child(kUSER_NOTES_T).child(notesRowKey).child("notes_users").observeSingleEvent(of: .value, with: { snapshot in
            if (snapshot.value as? [String: AnyObject]) != nil {
                 self.parsedFetchedData(childName: kUSER_NOTES_T, snapshot: snapshot, completion: completion, equalToFilterArr: nil)
            } else {
                completion(101, nil, "Data Fetch in Failed")
            }
        })
    }
    
    func fetchNotesCommentData(notesRowKey: String, userKey: String, completion: @escaping CompletionHandlerWithAnyObject) {
        ref.child(kUSER_NOTES_T).child(notesRowKey).child("notes_users").child(userKey).observeSingleEvent(of: .value, with: { snapshot in
            if let dic = snapshot.value as? [String: AnyObject] {
                completion(100, dic as AnyObject, "Data Fetch Successfully")
            } else {
                completion(101, nil, "Data Fetch in Failed")
            }
        })
    }

    func fetchNewsRequestData(rowKey: String, completion: @escaping CompletionHandlerWithAnyObject) {
        ref.child(kSPECIAL_ACCOUNT_REQUESTS).child(rowKey).observeSingleEvent(of: .value, with: { snapshot in
            if let authDic = snapshot.value as? [String: AnyObject] {
                completion(100, authDic as AnyObject, "Data Fetch Successfully")
            } else {
                completion(101, nil, "Data Fetch in Failed")
            }
        })
    }
    
    
    func reportUser(parameters: [String: AnyObject], completion: @escaping CompletionHandler) {
        var p = parameters
        p["updated_at"] = [".sv": "timestamp"] as AnyObject
        p["created_at"] = [".sv": "timestamp"] as AnyObject

        let email = p["email"] as! String
        let row_key = p["row_key"] as! String
        ref
            .child(kREPORT_USER)
            .child(email.stringKey())
            .child(row_key)
            .updateChildValues(p)

        let by_users = [currentUser!.email!.stringKey(): "1"] as [String: AnyObject]
        ref
            .child(kREPORT_USER)
            .child(email.stringKey())
            .child(row_key)
            .child(kReportedByUsers)
            .updateChildValues(by_users)

        var q = [String: AnyObject]()
        q["report_user"] = "1" as AnyObject

        if let type = parameters["type"] as? String {
            if type == "CONTENT_FEED_COMMENT" {
                var c = [String: AnyObject]()
                c["report_user_for_comment"] = "1" as AnyObject

                ref
                    .child(kPOSTS_LIST_T)
                    .child(parameters["row_key"] as! String)
                    .updateChildValues(c)

                ref
                    .child(kPOSTS_LIST_T)
                    .child(parameters["row_key"] as! String)
                    .child("comments")
                    .child(parameters["comment_row_key"] as! String)
                    .updateChildValues(q)

                ref
                    .child(kPOSTS_LIST_T)
                    .child(parameters["row_key"] as! String)
                    .child("comments")
                    .child(parameters["comment_row_key"] as! String)
                    .child(kReportedByUsers)
                    .updateChildValues(by_users)
            } else {
                ref
                    .child(kPOSTS_LIST_T)
                    .child(parameters["row_key"] as! String)
                    .updateChildValues(q)

                ref
                    .child(kPOSTS_LIST_T)
                    .child(parameters["row_key"] as! String)
                    .child(kReportedByUsers)
                    .updateChildValues(by_users)
            }
        }

        completion(100, nil, "You have reported this user to admin successfully.")
    }

    func blockUser(parameters: [String: AnyObject], completion: @escaping CompletionHandler) {
        var p = parameters
        p["updated_at"] = [".sv": "timestamp"] as AnyObject
        p["created_at"] = [".sv": "timestamp"] as AnyObject

        var blockUserKey = parameters["email"] as! String
        blockUserKey = blockUserKey.stringKey()
        ref.child(kBLOCK_USER).child(userKey).child(blockUserKey).setValue(1)
        ref.child(kBLOCK_USER).child(blockUserKey).child(userKey).setValue(1)

        completion(100, nil, "You have blocked the user successfully.")
    }

    func offensiveContentAction(parameters: [String: AnyObject], completion: @escaping CompletionHandler, isAdmin: Bool = false) {
        var p = parameters
        p["updated_at"] = [".sv": "timestamp"] as AnyObject
        p["created_at"] = [".sv": "timestamp"] as AnyObject

        if let type = parameters["type"] as? String {
            if type == "CONTENT_FEED_COMMENT" {
                var c = [String: AnyObject]()
                if let offensive_content = parameters["offensive_content"] as? String {
                    if offensive_content == "0" {
                        c["report_user_for_comment"] = "0" as AnyObject
                    } else {
                        c["report_user_for_comment"] = "1" as AnyObject
                    }
                } else {
                    c["report_user_for_comment"] = "0" as AnyObject
                }

                ref
                    .child(kPOSTS_LIST_T)
                    .child(parameters["row_key"] as! String)
                    .updateChildValues(c)

                p.removeValue(forKey: "comment_row_key")
                ref
                    .child(kPOSTS_LIST_T)
                    .child(parameters["row_key"] as! String)
                    .child("comments")
                    .child(parameters["comment_row_key"] as! String)
                    .updateChildValues(p)

                if isAdmin == false {
                    let by_users = [currentUser!.email!.stringKey(): "1"] as [String: AnyObject]

                    ref
                        .child(kPOSTS_LIST_T)
                        .child(parameters["row_key"] as! String)
                        .child("comments")
                        .child(parameters["comment_row_key"] as! String)
                        .child(kReportedByUsers)
                        .updateChildValues(by_users)
                }
            } else {
                ref.child(kPOSTS_LIST_T)
                    .child(parameters["row_key"] as! String)
                    .updateChildValues(p)

                if isAdmin == false {
                    let by_users = [currentUser!.email!.stringKey(): "1"] as [String: AnyObject]
                    ref.child(type)
                        .child(parameters["row_key"] as! String)
                        .child(kReportedByUsers)
                        .updateChildValues(by_users)
                }
            }

            completion(100, nil, "Marked offensive content successfully.")
        }
    }

    func loadMyBlockedUsers() {
        ref.child(kBLOCK_USER).child(userKey).observeSingleEvent(of: .value, with: { snapshot in

            if let userDic = snapshot.value as? [String: AnyObject] {
                self.myBlockedUsers = [String](userDic.keys)
            }
        })

        PWebService.sharedWebService.fetchRecord(childName: kUSERS_T,
                                                 queryChildName: "is_user_blocked_by_admin",
                                                 queryValue: "1" as AnyObject,
                                                 completion: { _, response, _ in
                                                     let filteredArray = PepsUser.modelsFromDictionaryArray(array: response as! NSArray)
                                                     for user in filteredArray {
                                                         if let u = user.email?.stringKey() {
                                                             self.myBlockedUsers.append(u)
                                                         }
                                                     }
        })
    }

}
