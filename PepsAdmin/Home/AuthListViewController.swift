//
//  AuthListViewController.swift
//  PepsAdmin
//
//  Created by Shubham Garg on 28/05/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import UIKit

class PAuthListViewController: UIViewController {
    @IBOutlet var authListTableView: UITableView!

    var userArr = [PepsUser]()
    override func viewDidLoad() {
        super.viewDidLoad()
        authListTableView.delegate = self
        authListTableView.dataSource = self
        authListTableView.tableFooterView = UIView(frame: .zero)
        getUserList()
    }

    func getUserList() {
        Helper.sharedHelper.showGlobalHUD(title: "", view: view)
        if Helper.sharedHelper.isNetworkAvailable() {
            PWebService.sharedWebService.fetchRecord(childName: kUSERS_T, queryChildName: "is_authenticate_user", queryValue: false as AnyObject, completion: { _, response, message in

                Helper.sharedHelper.dismissHUD(view: self.view)
                if response != nil {
                    let arr = PepsUser.modelsFromDictionaryArray(array: response as! NSArray)
                    self.userArr = arr as [PepsUser]
                    self.authListTableView.reloadData()
                } else {
                    Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
                }
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
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let authenticateVC = mainStoryboard.instantiateViewController(withIdentifier: PAuthenticateViewController.identifier) as? PAuthenticateViewController
        authenticateVC?.user = userArr[indexPath.row]
        navigationController?.pushViewController(authenticateVC!, animated: true)
    }
}

extension PAuthListViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return userArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PAuthTableViewCell.identifier, for: indexPath) as! PAuthTableViewCell
        cell.nameLbl.text = userArr[indexPath.row].full_name
        cell.worldwideIdLbl.text = userArr[indexPath.row].worldwide_id
        return cell
    }
}
