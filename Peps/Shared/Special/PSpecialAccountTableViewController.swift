//
//  PSpecialAccountTableViewController.swift
//  Peps
//
//  Created by KP Tech on 04/06/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import UIKit

class PSpecialAccountTableViewController: UITableViewController {
    let newsDataDic = [["key": "org_name", "type": "textCell", "title": "Name of News Org", "value": ""],
                       ["key": "company_name", "type": "textCell", "title": "Name of Company", "value": ""],
                       ["key": "is_official_rep", "type": "radioCell", "title": "Are you acting as an official Rep for this News Group?", "value": "1"],
                       ["key": "name_of_contact", "type": "textCell", "title": "Name of Contact", "value": ""],
                       ["key": "contact_info", "type": "textCell", "title": "Contact info", "value": ""],
                       ["key": "is_considered_news_outlet", "type": "radioCell", "title": "Is this what is normally considered a major News Outlet?", "value": "1"],
                       ["key": "is_niche_news_outlet", "type": "radioCell", "title": "Is this a niche News Outlet?", "value": "1"],
                       ["key": "interests", "type": "interestsCell", "title": "if Yes what areas is it focused on", "value": ""]]

    let contentAccountDataDic = [["key": "account_name", "type": "textCell", "title": "Account name", "value": ""],
                                 ["key": "interests", "type": "interestsCell", "title": "What interests will your content be geared towards?", "value": ""],
                                 ["key": "is_adult_material", "type": "radioCell", "title": "Will your account be geared towards adult material primarily?", "value": "1"],
                                 ["key": "message", "type": "messageCell", "title": "Any material/ account marked adult will only be made available on the Worldview Side of the account. It is upon the user to make sure that posts not marked adult contain no material sexual or sexually suggestive in nature. Selecting this option does not mean all your posts must be labeled as adult, however you will have to remove the adult content mark yourself when making a submission that does not pertain to adult content", "value": ""]]

    var modelArr = [PCellModel]()
    var rowKey = PWebService.sharedWebService.currentUser?.email ?? ""
    var fetchedDictionary: NSDictionary?
    @IBOutlet var submitView: UIView!
    @IBOutlet var submitBtn: UIButton!

    public enum RequestType: String {
        case none
        case worldwide
        case newsAccount
        case contentAccount
        case podcastAccount
    }

    var requestType: RequestType = .none

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = submitView

        if requestType == .newsAccount {
            for rowDic in newsDataDic {
                modelArr.append(PCellModel(dictionary: rowDic as NSDictionary))
            }
            title = "News Account Request"
        } else if requestType == .contentAccount || requestType == .podcastAccount {
            for rowDic in contentAccountDataDic {
                modelArr.append(PCellModel(dictionary: rowDic as NSDictionary))
            }
            title = requestType == .contentAccount ? "Content Account Request" : "Podcast Account Request"
        }

        if isAdminApp {
            submitBtn.setTitle("Approve", for: .normal)
        } else {
            PWebService.sharedWebService.fetchRecord(childName: kSPECIAL_ACCOUNT_REQUESTS,
                                                     queryChildName: "email",
                                                     queryValue: rowKey as AnyObject?,
                                                     equalToFilterArr: ["request_type": requestType.rawValue as AnyObject],
                                                     notEqualToFilterArr: nil) { _, response, _ in
                if let response = response as? [NSDictionary],
                    let fistObject = response.first {
                    self.fetchedDictionary = fistObject
                    self.tableView.reloadData()
                }
            }
        }
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return modelArr.count
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = modelArr[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: model.type, for: indexPath) as! PSpecialTableViewCell
        cell.delegate = self
        cell.renderData(cellModel: model, indexPath: indexPath, fetchedDictionary: fetchedDictionary)
        return cell
    }

    @IBAction func submitAction(_: Any) {
        var finalDic = [String: Any]()
        if isAdminApp {
            if let rowKey = fetchedDictionary?.value(forKey: "row_key") as? String,
                let email = fetchedDictionary?.value(forKey: "email") as? String,
                let requestType = fetchedDictionary?.value(forKey: "request_type") as? String {
                PWebService.sharedWebService.newsAccountRequestApprove(requestType: requestType,
                                                                       email: email,
                                                                       rowKey: rowKey,
                                                                       contentAccountName: fetchedDictionary?.value(forKey: "account_name") as? String,
                                                                       podcastAccountName: fetchedDictionary?.value(forKey: "account_name") as? String,
                                                                       newSiteName: fetchedDictionary?.value(forKey: "org_name") as? String,
                                                                       completion: { _, _, _ in
                                                                           self.showMessage("Request has been approved.", type: .success)
                                                                           self.navigationController?.popViewController(animated: true)
                })
            }

        } else {
            // check for all field validation
            for model in modelArr {
                if model.type == "messageCell" {
                    continue
                }
                if model.key != "interests" {
                    guard let value = model.value as? String, value != "" else {
                        // show error message
                        showMessage("Please fill all details", type: .warning)
                        return
                    }
                    finalDic[model.key] = value
                } else {
                    guard let value = model.value as? [String], value.count > 0 else {
                        // show error message
                        showMessage("Please fill all details", type: .warning)
                        return
                    }
                    finalDic[model.key] = value
                }
            }

            // After validation
            // prepare the dic
            finalDic["request_type"] = requestType.rawValue
            finalDic[kStatus] = 0 // submitted
            finalDic["email"] = PWebService.sharedWebService.currentUser?.email
            finalDic["user_id"] = PWebService.sharedWebService.currentUser?.user_id
            finalDic["first_name"] = PWebService.sharedWebService.currentUser?.first_name
            finalDic["last_name"] = PWebService.sharedWebService.currentUser?.last_name
            PWebService.sharedWebService.newsAccountRequest(requestType: requestType.rawValue,
                                                            parameters: finalDic as [String: AnyObject],
                                                            completion: { _, _, _ in
                                                                self.showMessage("Your request has been submitted.", type: .success)
                                                                self.navigationController?.popViewController(animated: true)
            })
        }
    }

    func requestNameType(requestTypeString: String) {
        if requestTypeString == "" {
            requestType = .none
        } else if requestTypeString == "newsAccount" {
            requestType = .newsAccount
        } else if requestTypeString == "contentAccount" {
            requestType = .contentAccount
        } else if requestTypeString == "podcastAccount" {
            requestType = .podcastAccount
        } else if requestTypeString == "worldwide" {
            requestType = .worldwide
        }
    }
}

extension PSpecialAccountTableViewController: PSpecialTableViewCellDelegate {
    func update(cellModel: PCellModel, indexPath: IndexPath) {
        modelArr[indexPath.row] = cellModel
        // self.tableView.reloadData()
    }

    func selectInterst(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}
