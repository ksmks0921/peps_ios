//
//  PLoginViewController.swift
//
//
//  Created by KP Tech on 10/12/18.
//  Copyright © 2018 kptech. All rights reserved.
//

import FirebaseAuth
import UIKit

class PLoginViewController: UIViewController {
    @IBOutlet var passwordTextField: DesignableUITextField!
    @IBOutlet var rememberMeBtn: UIButton!
    @IBOutlet var termsBtn: UIButton!
    @IBOutlet var emailTextField: DesignableUITextField!
    var loginEamil = NSString()
    var loginPassword = NSString()

    override func viewDidLoad() {
        super.viewDidLoad()
        rememberMeBtn.isSelected = true
        
        termsBtn.setImage(UIImage(named: "uncheckbox"), for: .normal)
        termsBtn.tag = 0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        let userObjDiec = userDefault.object(forKey: "loginDict") as? NSDictionary
        if userObjDiec != nil && rememberMeBtn.isSelected == true {
            emailTextField.text = userObjDiec![kEmail] as? String
            passwordTextField.text = userObjDiec!["password"] as? String
        } else {
            emailTextField.text = ""
            passwordTextField.text = ""
        }
    }

    @IBAction func loginAction(_: UIButton) {
        self.view.endEditing(true)
        
        if termsBtn.tag == 1 {
            if Helper.sharedHelper.isNetworkAvailable() {
                if emailTextField.text != "" && passwordTextField.text != "" {
                    if Helper.sharedHelper.validateEmailWithString(emailTextField.text! as NSString) {
                        let loginDict = NSMutableDictionary()
                        loginDict.setValue(emailTextField.text!, forKey: kEmail)
                        loginDict.setValue(passwordTextField.text!, forKey: kPasswordKey)
                        callApi(loginDict: loginDict)
                    } else {
                        Helper.sharedHelper.showGlobalAlertwithMessage("Enter valid email id", vc: self)
                    }
                } else {
                    Helper.sharedHelper.showGlobalAlertwithMessage("Enter enter login detail.", vc: self)
                }
            } else {
                DispatchQueue.main.async {
                    Helper.sharedHelper.ShowAlert(str: "No Internet Connection", viewcontroller: self)
                    Helper.sharedHelper.dismissHUD(view: self.view)
                }
            }
        } else {
            Helper.sharedHelper.showGlobalAlertwithMessage("Please accept the terms and conditions.", vc: self)
        }
    }

    func callApi(loginDict: NSMutableDictionary) {
        Helper.sharedHelper.showGlobalHUD(title: "Logging in...", view: view)

        PWebService.sharedWebService.webService(apiType: APIType.signInAccount, parameters: loginDict as! [String: AnyObject]) { status, response, message in

            Helper.sharedHelper.dismissHUD(view: self.view)

            if status == 100 {
                if APP_DELEGATE.fbUser == nil && self.rememberMeBtn.isSelected == true {
                    userDefault.set(response![kEmail], forKey: kEmail)
                    userDefault.set(loginDict, forKey: "loginDict")
                }
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let tabBarController = sb.instantiateInitialViewController() as! UITabBarController
                let navVC = UINavigationController(rootViewController: tabBarController)
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = navVC
                 appDelegate.window?.makeKeyAndVisible()
            } else {
                Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
            }
        }
    }

    @IBAction func signUpAction(_: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: PRegistrationViewController.identifier)
        navigationController?.pushViewController(vc!, animated: true)
    }

    @IBAction func facebokkLoginAction(_: UIButton) {
//        LoginManager().logIn(permissions: [kEmail], from: self) { _, error in
//            if error != nil {
////                print("Failed to login: \(error.localizedDescription)")
//                return
//            }
//            guard let accessToken = AccessToken.current else {
////                print("Failed to get access token")
//                return
//            }
//            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
//            // Perform login by calling Firebase APIs
//            Auth.auth().signInAndRetrieveData(with: credential) { _, error in
//                if let error = error {
////                    print("Login error: \(error.localizedDescription)")
//                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
//                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                    alertController.addAction(okayAction)
//                    self.present(alertController, animated: true, completion: nil)
//                    return
//                } else {
//                    self.getFBUserData()
//                }
//            }
//        }
    }

//    func getFBUserData() {
//        if (AccessToken.current) != nil {
//            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"]).start(completionHandler: { (_, result, error) -> Void in
//                if error == nil {
//                    let dict = result as! [String: AnyObject]
//                    if APP_DELEGATE.fbUser == nil {
//                        userDefault.set(dict[kEmail], forKey: kEmail)
//                        // userDefault.set(loginDict, forKey: "loginDict")
//                    }
//                    let sb = UIStoryboard(name: "Main", bundle: nil)
//                    let tabBarController = sb.instantiateInitialViewController() as! UITabBarController
//                    let navVC = UINavigationController(rootViewController: tabBarController)
//                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                    appDelegate.window?.rootViewController = navVC
//                }
//            })
//        }
//    }

    @IBAction func remembermeBtnAction(_ sender: UIButton) {
        if sender.isSelected == false {
            sender.isSelected = true
        } else {
            sender.isSelected = false
        }
    }
    
    @IBAction func termsAndConditionsAction(_ sender: UIButton) {
        if sender.isSelected == false {
            sender.isSelected = true
        } else {
            sender.isSelected = false
        }
        let mainStoryboard = UIStoryboard(name: "Terms", bundle: nil)
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "TermsDetailViewController") as! TermsDetailViewController
        vc.urlString = "Al2gether EULA and Terms-and-Conditions"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func checkBoxAction(_: Any) {
        if termsBtn.tag == 0 {
            termsBtn.setImage(UIImage(named: "checkbox"), for: .normal)
            termsBtn.tag = 1
        } else {
            termsBtn.setImage(UIImage(named: "uncheckbox"), for: .normal)
            termsBtn.tag = 0
        }
    }
}
