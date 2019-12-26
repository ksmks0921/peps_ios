//
//  PAuthListViewController.swift
//  PepsAdmin
//
//  Created by Shubham Garg on 28/05/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import UIKit

class PAuthListViewController: UIViewController {
    @IBOutlet var authListTableView: UITableView!
    var requests: [[[String: Any]]]?

    override func viewDidLoad() {
        super.viewDidLoad()
        authListTableView.delegate = self
        authListTableView.dataSource = self
        authListTableView.tableFooterView = UIView(frame: .zero)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        parent?.title = "Auth List"
        getWorldwideRequestList()
    }

    func getWorldwideRequestList() {
        requests = [[[String: Any]]]()
        Helper.sharedHelper.showGlobalHUD(title: "", view: view)
        if Helper.sharedHelper.isNetworkAvailable() {
            PWebService.sharedWebService.fetchRecord(childName: kWORLDWIDE_REQUEST_LIST_T,
                                                     queryChildName: kStatus,
                                                     queryValue: 0 as AnyObject,
                                                     completion: { _, response, _ in
                                                         Helper.sharedHelper.dismissHUD(view: self.view)
                                                         if let response = response as? [[String: AnyObject]] {
                                                             self.requests?.append(response)
                                                             self.authListTableView.reloadData()
                                                         }

                                                         PWebService.sharedWebService.fetchRecord(childName: kSPECIAL_ACCOUNT_REQUESTS,
                                                                                                  queryChildName: kStatus,
                                                                                                  queryValue: 0 as AnyObject,
                                                                                                  completion: { _, response, _ in
                                                                                                      if let response = response as? [[String: AnyObject]] {
                                                                                                          self.requests?.append(response)
                                                                                                          self.authListTableView.reloadData()
                                                                                                      }
                                                         })

            })

        } else {
            DispatchQueue.main.async {
                Helper.sharedHelper.ShowAlert(str: "No Internet Connection", viewcontroller: self)
                Helper.sharedHelper.dismissHUD(view: self.view)
            }
        }
    }
}

extension PAuthListViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = requests?[indexPath.section][indexPath.row] else {
            return
        }
        let requestType = user["request_type"] as? String ?? ""
        let rowKey = user["row_key"] as? String ?? ""
        if indexPath.section == 0 {
            let mainStoryboard = UIStoryboard(name: "Shared", bundle: nil)
            let authenticateVC = mainStoryboard.instantiateViewController(withIdentifier: PAuthenticateViewController.identifier) as? PAuthenticateViewController
            authenticateVC?.userKey = rowKey
            navigationController?.pushViewController(authenticateVC!, animated: true)
        } else {
            let mainStoryboard = UIStoryboard(name: "Shared", bundle: nil)
            let specialAccountViewController = mainStoryboard.instantiateViewController(withIdentifier: PSpecialAccountTableViewController.identifier) as? PSpecialAccountTableViewController
            specialAccountViewController?.rowKey = rowKey
            specialAccountViewController?.fetchedDictionary = user as NSDictionary
            specialAccountViewController?.requestNameType(requestTypeString: requestType)
            navigationController?.pushViewController(specialAccountViewController!, animated: true)
        }
    }
}

extension PAuthListViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return requests?.count ?? 0
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests?[section].count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PAuthTableViewCell.identifier, for: indexPath) as! PAuthTableViewCell
        guard let user = requests?[indexPath.section][indexPath.row] else {
            return cell
        }
        cell.nameLbl.text = "\(user["first_name"] ?? "") \(user["last_name"] ?? "")"
        cell.worldwideIdLbl.text = requestTypeName(requestType: user["request_type"] as? String ?? "")
        return cell
    }

    func requestTypeName(requestType: String) -> String {
        if requestType == "" {
            return ""
        } else if requestType == "newsAccount" {
            return "News Account"
        } else if requestType == "contentAccount" {
            return "Content Account"
        } else if requestType == "podcastAccount" {
            return "Podcast Account"
        } else if requestType == "worldwide" {
            return "Worldwide"
        }

        return ""
    }
}
