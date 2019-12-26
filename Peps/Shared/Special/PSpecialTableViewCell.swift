//
//  PSpecialTableViewCell.swift
//  Peps
//
//  Created by KP Tech on 04/06/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import UIKit
import ZFTokenField
protocol PSpecialTableViewCellDelegate {
    func update(cellModel: PCellModel, indexPath: IndexPath)
    func selectInterst(_ vc: UIViewController)
}

class PSpecialTableViewCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet var inputTextField: UITextField!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var yesButton: UIButton!
    @IBOutlet var noButton: UIButton!
    @IBOutlet var interestHeightConstant: NSLayoutConstraint!
    @IBOutlet var interestView: ZFTokenField!
    @IBOutlet var interestBtn: UIButton!
    @IBOutlet var messageLabel: UILabel?
    @IBOutlet var interestViewHeight: NSLayoutConstraint!
    var cellModel: PCellModel!
    var tokenHeight = CGFloat(20)
    var margin = CGFloat(4)
    var marginLbl = CGFloat(4)
    let AppColor = UIColor(red: 28.0 / 255.0, green: 96.0 / 255.0, blue: 159.0 / 255.0, alpha: 1.0)
    var selectedInterestArr = [String]()
    var delegate: PSpecialTableViewCellDelegate?
    var indexPath: IndexPath!

    func renderData(cellModel: PCellModel, indexPath: IndexPath, fetchedDictionary: NSDictionary?) {
        if interestView != nil {
            interestView.layer.cornerRadius = 0
        }
        self.cellModel = cellModel
        self.indexPath = indexPath
        if self.cellModel.type == "textCell" {
            inputTextField.placeholder = cellModel.title
            if let value = fetchedDictionary?.value(forKey: self.cellModel.key) as? String {
                inputTextField.text = value
                if isAdminApp {
                    inputTextField.isEnabled = false
                } else {
                    cellModel.value = value
                    delegate?.update(cellModel: cellModel, indexPath: indexPath)
                }
            }
        }
        if self.cellModel.type == "radioCell" {
            titleLabel.text = cellModel.title
            if let value = fetchedDictionary?.value(forKey: self.cellModel.key) as? String {
                if value == "0" {
                    yesButton.setImage(UIImage(named: "radio_inactive"), for: UIControl.State.normal)
                    noButton.setImage(UIImage(named: "radio_active"), for: UIControl.State.normal)
                } else {
                    yesButton.setImage(UIImage(named: "radio_active"), for: UIControl.State.normal)
                    noButton.setImage(UIImage(named: "radio_inactive"), for: UIControl.State.normal)
                }

                if isAdminApp {
                    yesButton.isEnabled = false
                    noButton.isEnabled = false
                } else {
                    cellModel.value = value
                    delegate?.update(cellModel: cellModel, indexPath: indexPath)
                }
            }
        }
        if self.cellModel.type == "interestsCell" {
            if let value = fetchedDictionary?.value(forKey: self.cellModel.key) as? [String] {
                selectedInterestArr = value
                interestView.reloadData()
                if isAdminApp {
                    isUserInteractionEnabled = false
                } else {
                    cellModel.value = value
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.delegate?.update(cellModel: self.cellModel, indexPath: self.indexPath)
                    }
                }
            }

            titleLabel.text = cellModel.title
        }

        if self.cellModel.type == "messageCell" {
            messageLabel?.text = cellModel.title
        }
    }

    @IBAction func yesAction(_: Any) {
        yesButton.setImage(UIImage(named: "radio_active"), for: UIControl.State.normal)
        noButton.setImage(UIImage(named: "radio_inactive"), for: UIControl.State.normal)
        cellModel.value = "1"
        delegate?.update(cellModel: cellModel, indexPath: indexPath)
    }

    @IBAction func noAction(_: Any) {
        yesButton.setImage(UIImage(named: "radio_inactive"), for: UIControl.State.normal)
        noButton.setImage(UIImage(named: "radio_active"), for: UIControl.State.normal)
        cellModel.value = "0"
        delegate?.update(cellModel: cellModel, indexPath: indexPath)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        cellModel.value = textField.text!
        delegate?.update(cellModel: cellModel, indexPath: indexPath)
    }

    @IBAction func interestBtnAction(_: UIButton) {
        let storyboard = UIStoryboard(name: "Shared", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: PInterestListViewController.identifier) as! PInterestListViewController
        vc.myDelegate = self
        vc.selectedInterests = selectedInterestArr
        delegate?.selectInterst(vc)
    }
}

/*
 [["key": "org_name", "type": "text", "title": "Name of News Org", "value": ""],
 ["key": "company_name", "type": "text", "title": "Name of Company", "value": ""],
 ["key": "is_official_rep", "type": "radio", "title": "Are you acting as an official Rep for this News Group?", "value": ""],
 ["key": "name_of_contact", "type": "text", "title": "Name of Contact", "value": ""],
 ["key": "contact_info", "type": "text", "title": "Contact info", "value": ""],
 ["key": "is_considered_news_outlet", "type": "radio", "title": "Is this what is normally considered a major News Outlet?", "value": ""]
 ["key": "is_niche_news_outlet", "type": "radio", "title": "Is this a niche News Outlet?", "value": ""],
 ["key": "interests", "type": "interest", "title": "Is this a niche News Outlet?", "value": ""]]
 */

extension PSpecialTableViewCell: IntersetsListDelegate {
    func selectedInterestArr(arr: [String]) {
        cellModel.value = arr
        selectedInterestArr = arr
        interestView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.delegate?.update(cellModel: self.cellModel, indexPath: self.indexPath)
        }
    }
}

extension PSpecialTableViewCell: ZFTokenFieldDelegate, ZFTokenFieldDataSource {
    func tokenFieldDidEndEditing(_ tokenField: ZFTokenField!) {
//        print(tokenField.frame.height)
    }

    func tokenMarginInToken(in _: ZFTokenField!) -> CGFloat {
        return marginLbl
    }

    func lineHeightForToken(in _: ZFTokenField!) -> CGFloat {
        return tokenHeight
    }

    func numberOfToken(in _: ZFTokenField!) -> UInt {
        return UInt(selectedInterestArr.count)
    }

    func tokenField(_ tokenField: ZFTokenField!, viewForTokenAt index: UInt) -> UIView! {
        tokenField.textField.isEnabled = false

        var title = String()

        title = selectedInterestArr[NSInteger(index)]

        // let title = selectedUsersListArr.allKeys[NSInteger(index)]

        let testLbl1 = UILabel()
        testLbl1.text = " \(title) " // " + title! + "  "
        testLbl1.font = UIFont.systemFont(ofSize: 14)
        testLbl1.sizeToFit()

        var testLbl1Frame = testLbl1.frame
        testLbl1Frame.size.height = tokenHeight
        testLbl1.frame = testLbl1Frame

        testLbl1.layer.cornerRadius = marginLbl
        testLbl1.backgroundColor = AppColor
        testLbl1.textColor = UIColor.white

        testLbl1.clipsToBounds = true

        return testLbl1
    }
}
