//
//  PMoreViewController.swift
//  ReRoute
//
//  Created by Shubham Garg on 18/05/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import FirebaseAuth
import UIKit

class PMoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parent?.title = "More"
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")

        if indexPath.row == 0 {
            cell?.textLabel?.text = "Profile"
        } else {
            cell?.textLabel?.text = "Logout"
        }

        return cell!
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let sb = UIStoryboard(name: "Login", bundle: nil)
            let updateProfileVC = sb.instantiateViewController(withIdentifier: PRegistrationViewController.identifier) as! PRegistrationViewController
            updateProfileVC.editProfile = 1
            navigationController?.pushViewController(updateProfileVC, animated: true)
        } else {
            try! Auth.auth().signOut()
            let userDefaults = UserDefaults.standard
            userDefaults.set(nil, forKey: "CurrentUser")
            userDefaults.synchronize()

            let sb = UIStoryboard(name: "Login", bundle: nil)
            let loginController = sb.instantiateInitialViewController() as! PLoginViewController
            let navVC = UINavigationController(rootViewController: loginController)
            navigationController?.present(navVC, animated: true, completion: nil)
        }
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 50
    }
}
