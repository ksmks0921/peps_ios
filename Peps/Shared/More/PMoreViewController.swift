//
//  PMoreViewController.swift
//  ReRoute
//
//  Created by Shubham Garg on 18/05/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import FirebaseAuth
import UIKit

class PMoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MoretDelegate {
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()

        let headerNib = UINib(nibName: "PMoreSubView", bundle: Bundle.main)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "PMoreSubView")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parent?.title = "More"
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if isAdminApp {
            return 2
        }
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")

        if isAdminApp {
            if indexPath.row == 0 {
                cell?.textLabel?.text = "Profile"
            } else {
                cell?.textLabel?.text = "Logout"
            }
            return cell!
        }

        cell?.accessoryType = .none
        if indexPath.row == 0 {
            cell?.detailTextLabel?.text = ""
            cell?.textLabel?.text = "Profile"
            cell?.accessoryType = .disclosureIndicator
        } else if indexPath.row == 1 {
            if let status = PWebService.sharedWebService.currentUser?.is_news_account_available {
                cell?.textLabel?.text = "Request For News Account"
                if status == 2 {
                    cell?.textLabel?.text = "News Account"
                    cell?.detailTextLabel?.text = "Approved"
                    cell?.isUserInteractionEnabled = false
                    cell?.detailTextLabel?.textColor = UIColor.green
                } else if status == 1 {
                    cell?.detailTextLabel?.text = "Submitted"
                    cell?.isUserInteractionEnabled = false
                    cell?.detailTextLabel?.textColor = UIColor.red
                } else {
                    cell?.detailTextLabel?.text = ""
                    cell?.accessoryType = .disclosureIndicator
                    cell?.isUserInteractionEnabled = true
                }
            } else {
                cell?.detailTextLabel?.text = ""
                cell?.accessoryType = .disclosureIndicator
                cell?.isUserInteractionEnabled = true
            }
        } else if indexPath.row == 2 {
            cell?.textLabel?.text = "Request For Content Account"
            if let status = PWebService.sharedWebService.currentUser?.is_content_account_available {
                if status == 2 {
                    cell?.textLabel?.text = "Content Account"
                    cell?.detailTextLabel?.text = "Approved"
                    cell?.detailTextLabel?.textColor = UIColor.green
                    cell?.isUserInteractionEnabled = false
                } else if status == 1 {
                    cell?.detailTextLabel?.text = "Submitted"
                    cell?.isUserInteractionEnabled = false
                    cell?.detailTextLabel?.textColor = UIColor.red
                } else {
                    cell?.detailTextLabel?.text = ""
                    cell?.accessoryType = .disclosureIndicator
                    cell?.isUserInteractionEnabled = true
                }
            } else {
                cell?.detailTextLabel?.text = ""
                cell?.accessoryType = .disclosureIndicator
                cell?.isUserInteractionEnabled = true
            }

        } else if indexPath.row == 3 {
            cell?.textLabel?.text = "Request For Podcast Account"
            if let status = PWebService.sharedWebService.currentUser?.is_podcast_account_available {
                if status == 2 {
                    cell?.textLabel?.text = "Podcast Account"
                    cell?.detailTextLabel?.text = "Approved"
                    cell?.isUserInteractionEnabled = false
                    cell?.detailTextLabel?.textColor = UIColor.green
                } else if status == 1 {
                    cell?.detailTextLabel?.text = "Submitted"
                    cell?.isUserInteractionEnabled = false
                    cell?.detailTextLabel?.textColor = UIColor.red
                } else {
                    cell?.detailTextLabel?.text = ""
                    cell?.accessoryType = .disclosureIndicator
                    cell?.isUserInteractionEnabled = true
                }
            } else {
                cell?.detailTextLabel?.text = ""
                cell?.accessoryType = .disclosureIndicator
                cell?.isUserInteractionEnabled = true
            }
        }

        return cell!
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let sb = UIStoryboard(name: "Login", bundle: nil)
            let updateProfileVC = sb.instantiateViewController(withIdentifier: PRegistrationViewController.identifier) as! PRegistrationViewController
            updateProfileVC.user = PWebService.sharedWebService.currentUser
            updateProfileVC.editProfile = 1
            navigationController?.pushViewController(updateProfileVC, animated: true)
        } else if indexPath.row == 1 {
            if (PWebService.sharedWebService.currentUser?.is_news_account_available ?? 0) == 2 {
                let vc = storyboard?.instantiateViewController(withIdentifier: PCreatePostViewController.identifier) as! PCreatePostViewController
                vc.postType = .newsSiteFeed
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let sb = UIStoryboard(name: "Shared", bundle: nil)
                let specialAccountViewController = sb.instantiateViewController(withIdentifier: PSpecialAccountTableViewController.identifier) as! PSpecialAccountTableViewController
                specialAccountViewController.requestType = .newsAccount
                navigationController?.pushViewController(specialAccountViewController, animated: true)
            }
        } else if indexPath.row == 2 {
            if (PWebService.sharedWebService.currentUser?.is_content_account_available ?? 0) == 2 {
                let vc = storyboard?.instantiateViewController(withIdentifier: PCreatePostViewController.identifier) as! PCreatePostViewController
                vc.postType = .contentFeed
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let sb = UIStoryboard(name: "Shared", bundle: nil)
                let specialAccountViewController = sb.instantiateViewController(withIdentifier: PSpecialAccountTableViewController.identifier) as! PSpecialAccountTableViewController
                specialAccountViewController.requestType = .contentAccount
                navigationController?.pushViewController(specialAccountViewController, animated: true)
            }
        } else if indexPath.row == 3 {
            if (PWebService.sharedWebService.currentUser?.is_podcast_account_available ?? 0) == 2 {
                let vc = storyboard?.instantiateViewController(withIdentifier: PCreatePostViewController.identifier) as! PCreatePostViewController
                vc.postType = .podcastFeed
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let sb = UIStoryboard(name: "Shared", bundle: nil)
                let specialAccountViewController = sb.instantiateViewController(withIdentifier: PSpecialAccountTableViewController.identifier) as! PSpecialAccountTableViewController
                specialAccountViewController.requestType = .podcastAccount
                navigationController?.pushViewController(specialAccountViewController, animated: true)
            }
        }
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection _: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PMoreSubView") as! PMoreSubView
        headerView.delegate = self
        return headerView
    }

    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        return 80
    }

    func logOutBtnAction(logout _: UIButton) {
        try! Auth.auth().signOut()
        let userDefaults = UserDefaults.standard
        userDefaults.set(nil, forKey: "CurrentUser")
        userDefaults.synchronize()
        let sb = UIStoryboard(name: "Login", bundle: nil)
        let loginController = sb.instantiateViewController(withIdentifier: "PLoginViewController") as! PLoginViewController
        let navVC = UINavigationController(rootViewController: loginController)
        navVC.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = navVC
            appDelegate.window?.makeKeyAndVisible()
            
        }
    }
}
