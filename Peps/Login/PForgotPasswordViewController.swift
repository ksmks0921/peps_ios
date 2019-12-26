//
//  PForgotPasswordViewController.swift
//
//
//  Created by KP Tech on 10/12/18.
//  Copyright © 2018 kptech. All rights reserved.
//

import UIKit

class PForgotPasswordViewController: UIViewController {
    @IBOutlet var emailTextFiled: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.topItem?.title = ""
        title = "ForgotPassword"
    }

    @IBAction func backAction(_: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func submitAction(_: UIButton) {
        view.endEditing(true)

        if Helper.sharedHelper.isNetworkAvailable() {
            if Helper.sharedHelper.validateEmailWithString(emailTextFiled.text! as NSString) {
                Helper.sharedHelper.showGlobalHUD(title: "Logging in...", view: view)

                PWebService.sharedWebService.webService(apiType: .forgotPassowrdAnAccount, parameters: [kEmailKey: self.emailTextFiled.text! as AnyObject], completion: { status, _, message in
                    Helper.sharedHelper.dismissHUD(view: self.view)

                    if status == 100 {
                        Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)

                        self.emailTextFiled.text = ""
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
                    }
                })
            } else {
                Helper.sharedHelper.ShowAlert(str: "Enter valid email id", viewcontroller: self)
            }
        }
    }
}
