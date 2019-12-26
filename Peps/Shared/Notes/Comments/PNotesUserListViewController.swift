//
//  PNotesUserListViewController.swift
//  Peps
//
//  Created by Shubham Garg on 05/11/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import Foundation



class PNotesUserListViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    var commentsUsers: [[String: Any]]?
    public var notes_row_key: String = ""
    public var notes:PNotesModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        parent?.title = "Comments"
        getNotesUserList()
    }
    
    func getNotesUserList() {
        commentsUsers = [[String: Any]]()
        Helper.sharedHelper.showGlobalHUD(title: "", view: view)
        if Helper.sharedHelper.isNetworkAvailable() {
            PWebService.sharedWebService.fetchNotesCommentForCreater(notesRowKey: notes_row_key) { _, response, _ in
                Helper.sharedHelper.dismissHUD(view: self.view)
                if let response = response as? [[String: AnyObject]] {
                    self.commentsUsers = response
                    self.tableView.reloadData()
                }
                
            }
            
        } else {
            DispatchQueue.main.async {
                Helper.sharedHelper.ShowAlert(str: "No Internet Connection", viewcontroller: self)
                Helper.sharedHelper.dismissHUD(view: self.view)
            }
        }
    }
}

extension PNotesUserListViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = commentsUsers?[indexPath.row] else {
            return
        }
        let rowKey = user["row_key"] as? String ?? ""
        if indexPath.section == 0 {
            let mainStoryboard = UIStoryboard(name: "Shared", bundle: nil)
            let vc = mainStoryboard.instantiateViewController(withIdentifier: PNotesCommentsViewController.identifier) as? PNotesCommentsViewController
            vc?.userKey = rowKey
            vc?.notes_row_key = self.notes_row_key
            vc?.isCreater = true
            vc?.notes = self.notes
            navigationController?.pushViewController(vc!, animated: true)
        }
    }
}

extension PNotesUserListViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }
    
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsUsers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PNotesCommentTableViewCell.identifier, for: indexPath) as! PNotesCommentTableViewCell
        guard let user = commentsUsers?[indexPath.row] else {
            return cell
        }
        cell.nameLbl.text = "\(user["first_name"] ?? "") \(user["last_name"] ?? "")"
        return cell
    }
    
}
