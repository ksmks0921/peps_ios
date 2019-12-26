//
//  PNotesCommentsViewController.swift
//  Peps
//
//  Created by Shubham Garg on 05/11/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import Foundation

class PNotesCommentsViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var commentTextField: UITextField!
     @IBOutlet var headerView: UIView!
    var comments: [PComments]? = []
    public var notes_row_key: String = ""
    var userKey = PWebService.sharedWebService.userKey
    var isCreater = false
    public var notes:PNotesModel?
    
    override func viewDidLoad() {
    super.viewDidLoad()
        if !isCreater{
            let dict = NSMutableDictionary()
            dict.setValue(PWebService.sharedWebService.currentUser?.first_name, forKey: kFName)
            dict.setValue(PWebService.sharedWebService.currentUser?.last_name, forKey: kLName)
            dict.setValue(PWebService.sharedWebService.currentUser?.email!, forKey: kEmail)
            dict.setValue(PWebService.sharedWebService.currentUser?.image_url, forKey: "profile_url")
            dict.setValue(PWebService.sharedWebService.currentUser?.user_id, forKey: kUser_Id)
            PWebService.sharedWebService.updateNotesUser(notesRowKey: notes_row_key, parameters: dict as! [String : AnyObject]) { (_, response, _) in
                print(response ?? [:])
            }
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.keyboardWillHide))
               view.addGestureRecognizer(tap)
               headerView.layer.borderColor = UIColor.lightGray.cgColor
               headerView.layer.borderWidth = 0.5
        fetchRecord()
    }
    
    
    func fetchRecord() {
        Helper.sharedHelper.showGlobalHUD(title: "", view: view)
        PWebService.sharedWebService.fetchNotesCommentData(notesRowKey: notes_row_key, userKey: userKey) { _, response, _ in
               if let response = response as? NSDictionary {
                   let data = AuthData(dictionary: response)
                self.comments = data?.comments
                Helper.sharedHelper.dismissHUD(view: self.view)
                   self.tableView.reloadData()
               }
           }
       }
    
    
    @IBAction func sendCommentAction(_: UIButton) {
        if let text = commentTextField.text {
            guard let user = PWebService.sharedWebService.currentUser else {
                return
            }
            Helper.sharedHelper.showGlobalHUD(title: "Posting...", view: view)
            let commentsdict = NSMutableDictionary()
            commentsdict.setValue(text, forKey: "comment_text")
            if isCreater{
                commentsdict.setValue(notes?.notesFrom, forKey: "user_name")
            }
            else{
                commentsdict.setValue(user.full_name, forKey: "user_name")
            }
            
            commentsdict.setValue(user.email, forKey: kEmail)
            commentsdict.setValue(user.image_url, forKey: "profile_url")
            commentsdict.setValue(user.user_id, forKey: kUser_Id)
            PWebService.sharedWebService.addNotesComment(parameters: commentsdict as! [String: AnyObject], notesRowKey: notes_row_key,
                                                        userKey: userKey,
                                                        completion: { _, _, _ in
                                                            Helper.sharedHelper.dismissHUD(view: self.view)
                                                            self.commentTextField.text = ""
                                                            // Fetch comments
                                                            self.fetchRecord()

            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        view.endEditing(true)
    }
    
}
extension PNotesCommentsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let comment = comments?[indexPath.row]
        cell?.textLabel?.text = comment?.user_name
        cell?.detailTextLabel?.text = comment?.comment_text
        return cell!
    }

    func numberOfSections(in _: UITableView) -> Int {
        if comments?.count == 0 {
            return 0
        }
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return comments?.count ?? 0
    }

    func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        return headerView
       
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 50
    }
}
