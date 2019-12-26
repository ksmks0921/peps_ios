//
//  PCommentViewController.swift
//  Peps
//
//  Created by Shubham Garg on 29/06/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import IQKeyboardManagerSwift
import UIKit

class PCommentViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var commentTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    var postOBJ: PHomePosts?
    var postType: HomeScreenType = .home

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Comments"
        IQKeyboardManager.shared.enableAutoToolbar = false
    }

    @IBAction func sendCommentAction(_: UIButton) {
        view.endEditing(true)
        guard commentTextField.text != "" else {
            Helper.sharedHelper.showGlobalAlertwithMessage("Please enter the comments.")
            return
        }

        sendComment(commentString: commentTextField.text!, postDetails: postOBJ!)
        commentTextField.text = ""
    }

    func sendComment(commentString: String, postDetails: PHomePosts) {
        Helper.sharedHelper.showGlobalHUD(title: "Posting...", view: view)

        let commentsdict = NSMutableDictionary()
        commentsdict.setValue(commentString, forKey: "comment_text")
        switch postType {
        case .home:
            commentsdict.setValue(PWebService.sharedWebService.currentUser?.user_id!, forKey: "user_name")
        case .worldwide:
            commentsdict.setValue(PWebService.sharedWebService.currentUser?.worldwide_user_id!, forKey: "user_name")
        case .myProfileNewsSite:
            commentsdict.setValue(PWebService.sharedWebService.currentUser?.news_site_name!, forKey: "user_name")
        case .myProfileContentAccount:
            commentsdict.setValue(PWebService.sharedWebService.currentUser?.content_account_name!, forKey: "user_name")
        case .myProfilePodcast:
            commentsdict.setValue(PWebService.sharedWebService.currentUser?.podcast_account_name!, forKey: "user_name")
        case .none:
            commentsdict.setValue(PWebService.sharedWebService.currentUser?.full_name!, forKey: "user_name")
        case .myProfileHome:
            commentsdict.setValue(PWebService.sharedWebService.currentUser?.user_id!, forKey: "user_name")
        case .myProfileWorldwide:
            commentsdict.setValue(PWebService.sharedWebService.currentUser?.worldwide_user_id!, forKey: "user_name")
        case .notes:
            break
        }
        commentsdict.setValue(PWebService.sharedWebService.currentUser?.email, forKey: kEmail)
        commentsdict.setValue(PWebService.sharedWebService.currentUser?.image_url, forKey: "profile_url")
        PWebService.sharedWebService.addComments(parameters: commentsdict as! [String: AnyObject], rowKey: postDetails.row_Key!, childName: kPOSTS_LIST_T, receiverEmail: postDetails.email!.stringKey()) { status, _, message in

            Helper.sharedHelper.dismissHUD(view: self.view)

            if status == 100 {
                if self.postOBJ?.comments == nil {
                    self.postOBJ?.comments = NSMutableArray()
                }
                self.postOBJ?.comments?.add(commentsdict as Any)
                self.tableView.reloadData()
            } else {
                Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
            }
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension PCommentViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if let obj = postOBJ, let comments = obj.comments {
            let commentsObj = PComments.modelsFromDictionaryArray(array: comments)
            return commentsObj.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPostCommentViewCell.identifier) as! PPostCommentViewCell
        let commentsObj = PComments.modelsFromDictionaryArray(array: (postOBJ?.comments)!)
        let comments = commentsObj[indexPath.row]
        cell.setdata(detailDataObj: comments, indexPath: indexPath)
        cell.cellDelegate = self

        return cell
    }

    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {}

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension PCommentViewController: PPostCommentViewCellDelegate {
    func deleteAction(comment: PComments, moreBtn: UIButton, indexPath: IndexPath) {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let secondAction: UIAlertAction = UIAlertAction(title: "Delete", style: .default) { _ -> Void in
            let post = self.postOBJ
            PWebService.sharedWebService.deleteComment(tableKey: kPOSTS_LIST_T, postKey: post?.row_Key ?? "nokey", comment: comment, completion: { _, _, _ in
                self.postOBJ?.comments?.removeObject(at: indexPath.row)
                self.tableView.reloadData()
            })
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { _ -> Void in }
        // add actions
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(cancelAction)

        if let presenter = actionSheetController.popoverPresentationController {
            presenter.sourceView = moreBtn
            presenter.sourceRect = moreBtn.bounds
        }

        present(actionSheetController, animated: true, completion: nil)
    }
    
    func otherUserPostCreatedAction(comment: PComments, moreButton: UIButton) {
        // create an actionSheet
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // create an action
        let firstAction: UIAlertAction = UIAlertAction(title: "Report User", style: .default) { _ -> Void in

            Helper.sharedHelper.showGlobalHUD(title: "", view: self.view)

            var parameters = [String: AnyObject]()
            parameters["email"] = comment.email as AnyObject
            parameters["comment_row_key"] = comment.row_key as AnyObject
            parameters["row_key"] = self.postOBJ?.row_Key as AnyObject
            parameters["type"] = "CONTENT_FEED_COMMENT" as AnyObject

            PWebService.sharedWebService.reportUser(parameters: parameters, completion: { _, _, message in
                Helper.sharedHelper.dismissHUD(view: self.view)
                Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
            })
        }

        let secondAction: UIAlertAction = UIAlertAction(title: "Block User", style: .default) { _ -> Void in

            Helper.sharedHelper.showGlobalHUD(title: "", view: self.view)

            var parameters = [String: AnyObject]()
            parameters["email"] = comment.email as AnyObject
            parameters["comment_row_key"] = comment.row_key as AnyObject
            parameters["row_key"] = self.postOBJ?.row_Key as AnyObject
            parameters["type"] = "CONTENT_FEED_COMMENT" as AnyObject

            PWebService.sharedWebService.blockUser(parameters: parameters, completion: { _, _, message in
                Helper.sharedHelper.dismissHUD(view: self.view)
                Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
                self.postOBJ?.comments?.remove(comment)
                self.tableView.reloadData()
            })
        }

        let offensiveAction: UIAlertAction = UIAlertAction(title: "Offensive or inappropriate content.", style: .default) { _ -> Void in

            Helper.sharedHelper.showGlobalHUD(title: "", view: self.view)

            var parameters = [String: AnyObject]()
            parameters["email"] = comment.email as AnyObject
            parameters["comment_row_key"] = comment.row_key as AnyObject
            parameters["row_key"] = self.postOBJ?.row_Key as AnyObject
            parameters["type"] = "CONTENT_FEED_COMMENT" as AnyObject
            parameters["offensive_content"] = "1" as AnyObject

            PWebService.sharedWebService.offensiveContentAction(parameters: parameters, completion: { _, _, message in
                Helper.sharedHelper.dismissHUD(view: self.view)
                Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
                self.postOBJ?.comments?.remove(comment)
                self.tableView.reloadData()
            })
        }

        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { _ -> Void in }

        // add actions
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(offensiveAction)
        actionSheetController.addAction(cancelAction)

        if let presenter = actionSheetController.popoverPresentationController {
            presenter.sourceView = moreButton
            presenter.sourceRect = moreButton.bounds
        }

        // present an actionSheet...
        present(actionSheetController, animated: true, completion: nil)
    }
}
