//
//  PRegistrationViewController.swift
//
//
//  Created by KP Tech on 10/12/18.
//  Copyright © 2018 kptech. All rights reserved.
//

import Firebase
import UIKit
import ZFTokenField

class PRegistrationViewController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet var genderView: UIView!
    @IBOutlet var interestViewHeight: NSLayoutConstraint!
    @IBOutlet var firstnameTextField: UITextField!
    @IBOutlet var genderTextField: UITextField!
    @IBOutlet var userIdTextField: UITextField!
    @IBOutlet var termsBtn: UIButton!
    @IBOutlet var loginBtn: UIButton!
    @IBOutlet var signUpBtn: UIButton!
    @IBOutlet var lastnameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var passwordView: UIView!
    @IBOutlet var confirmPasswordView: UIView!
    @IBOutlet var confirmpasswordTextField: UITextField!
    @IBOutlet var birtdateTF: UITextField!
    @IBOutlet var maleBtn: UIButton!
    @IBOutlet var femaleBtn: UIButton!
    @IBOutlet var publicBtn: UIButton!
    @IBOutlet var nonPublicBtn: UIButton!
    @IBOutlet var firstNameView: UIView!

    @IBOutlet var otherBtn: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var interestHeightConstant: NSLayoutConstraint!
    @IBOutlet var interestView: ZFTokenField!
    @IBOutlet var interestBtn: UIButton!
    var selectedInterestArr = [String]()
    var genderType = "male"
    var firstNamePublic = true

    var editProfile = 0
    var picker = UIImagePickerController()
    var signUpDict = NSMutableDictionary()
    var myPickerView: UIPickerView?
    var toolBar: UIToolbar?
    var tokenHeight = CGFloat(20)
    var margin = CGFloat(4)
    var marginLbl = CGFloat(4)
    var user: PepsUser?
    var imageChanged = false
    var genderData = ["Not Mention", "Agender", "Androgyne", "Androgynous", "Bigender", "Cisgender", "Cis Female", "Cis Male", "Cis Man", "Cis Woman", "Cisgender Female", "Cisgender Male", "Cisgender Man", "Cisgender Woman", "Female to Male", "FTM", "Gender Fluid", "Gender Nonconforming", "Gender Questioning", "Gender Variant", "Genderqueer", "Intersex", "Male to Female", "MTF", "Neither", "Neutrois", "Non-binary", "Other", "Pangender", "Trans", "Trans*", "Trans Female", "Trans* Female", "Trans Male", "Trans* Male", "Trans Man", "Trans* Man", "Trans Person", "Trans* Person", "Trans Woman", "Trans* Woman", "Transfeminine", "Transgender", "Transgender Female", "Transgender Male", "Transgender Man", "Transgender Person", "Transgender Woman", "Transmasculine", "Transsexual", "Transsexual Female", "Transsexual Male", "Transsexual Man", "Transsexual Person", "Transsexual Woman", "Two-Spirit"]

    let datePicker = UIDatePicker()
    var screenType = HomeScreenType.none

    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        termsBtn.setImage(UIImage(named: "uncheckbox"), for: .normal)
        termsBtn.tag = 0
        title = "Create An Account"
        if editProfile == 2 {
            profileViewFlow()
            editProfileFlow()
        } else if editProfile == 1 {
            editProfileFlow()
        } else {
            genderView.isUserInteractionEnabled = true
            maleBtn.setImage(UIImage(named: "radio_active"), for: UIControl.State.normal)
            femaleBtn.setImage(UIImage(named: "radio_inactive"), for: UIControl.State.normal)
            genderTextField.placeholder = "Other"
            genderTextField.text = ""
            
            publicBtn.setImage(UIImage(named: "radio_active"), for: UIControl.State.normal)
            nonPublicBtn.setImage(UIImage(named: "radio_inactive"), for: UIControl.State.normal)

        }

        if selectedInterestArr.count > 0 {
            interestHeightConstant.constant = 14
            interestView.reloadData()
        }
        pickUp()
    }

    func setScreenType() {
        switch screenType {
        case .none,.home, .myProfileHome:
            userIdTextField.placeholder = "User Id"
            userIdTextField.text = user?.user_id
        case .worldwide, .myProfileWorldwide:
            userIdTextField.placeholder = "Worldwide User Id"
            userIdTextField.text = user?.worldwide_user_id
        case .myProfileContentAccount:
            userIdTextField.placeholder = "Content User Id"
            userIdTextField.text = user?.content_account_name
        case .myProfilePodcast:
            userIdTextField.placeholder = "Podcast User Id"
            userIdTextField.text = user?.podcast_account_name
        case .myProfileNewsSite:
            userIdTextField.placeholder = "News User Id"
            userIdTextField.text = user?.news_site_name
        case .notes:
            break
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        interestView.layer.cornerRadius = 0
        super.viewWillAppear(animated)
    }

    func editProfileFlow() {
        title = "Profile"
        if user?.email != PWebService.sharedWebService.currentUser?.email {
            signUpBtn.isHidden = true
        } else {
            signUpBtn.isHidden = false
        }
        signUpBtn.setTitle("Update Profile", for: .normal)
        imageView.sd_setImage(with: URL(string: user?.image_url ?? ""), placeholderImage: UIImage(named: "user"))
        loginBtn.isHidden = true
        passwordView.removeFromSuperview()
        confirmPasswordView.removeFromSuperview()
        firstnameTextField.text = user?.first_name
        lastnameTextField.text = user?.last_name
        emailTextField.text = user?.email
        emailTextField.isUserInteractionEnabled = false
        birtdateTF.text = user?.date_of_birth
        birtdateTF.isUserInteractionEnabled = false
        genderTextField.placeholder = "Other"
        if user?.gender?.lowercased() == "male" {
            maleBtn.setImage(UIImage(named: "radio_active"), for: UIControl.State.normal)
            femaleBtn.setImage(UIImage(named: "radio_inactive"), for: UIControl.State.normal)
        } else if user?.gender?.lowercased() == "female" {
            maleBtn.setImage(UIImage(named: "radio_inactive"), for: UIControl.State.normal)
            femaleBtn.setImage(UIImage(named: "radio_active"), for: UIControl.State.normal)
        } else {
            maleBtn.setImage(UIImage(named: "radio_inactive"), for: UIControl.State.normal)
            femaleBtn.setImage(UIImage(named: "radio_inactive"), for: UIControl.State.normal)
            genderTextField.text = user?.genderOther ?? ""
        }
        
        if user?.name_public == true {
            publicBtn.setImage(UIImage(named: "radio_active"), for: UIControl.State.normal)
            nonPublicBtn.setImage(UIImage(named: "radio_inactive"), for: UIControl.State.normal)
        } else {
//            publicBtn.setImage(UIImage(named: "radio_inactive"), for: UIControl.State.normal)
//            nonPublicBtn.setImage(UIImage(named: "radio_active"), for: UIControl.State.normal)
            firstNameView.removeFromSuperview()
        }
        
        selectedInterestArr = user?.interests ?? []
        setScreenType()
    }

    func profileViewFlow() {
        let isEnabled = false
        let isHidden = true
        firstnameTextField.isEnabled = isEnabled
        lastnameTextField.isEnabled = isEnabled
        genderTextField.isEnabled = isEnabled
        userIdTextField.isEnabled = isEnabled
        emailTextField.isEnabled = isEnabled
        passwordTextField.isEnabled = isEnabled
        confirmpasswordTextField.isEnabled = isEnabled
        birtdateTF.isEnabled = isEnabled
        maleBtn.isEnabled = isEnabled
        femaleBtn.isEnabled = isEnabled
        interestBtn.isEnabled = isEnabled

        loginBtn.isHidden = isHidden
        signUpBtn.isHidden = isHidden
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func backBtnAction(_: Any) {
        navigationController?.popViewController(animated: true)
    }
    
     @IBAction func publicBtnAction(_: UIButton) {
        publicBtn.setImage(UIImage(named: "radio_active"), for: UIControl.State.normal)
        nonPublicBtn.setImage(UIImage(named: "radio_inactive"), for: UIControl.State.normal)
        firstNamePublic = true
    }
    
     @IBAction func nonPublicBtnAction(_: UIButton) {
        nonPublicBtn.setImage(UIImage(named: "radio_active"), for: UIControl.State.normal)
        publicBtn.setImage(UIImage(named: "radio_inactive"), for: UIControl.State.normal)
        firstNamePublic = false
    }

    @IBAction func maleBtnAction(_: UIButton) {
        maleBtn.setImage(UIImage(named: "radio_active"), for: UIControl.State.normal)
        femaleBtn.setImage(UIImage(named: "radio_inactive"), for: UIControl.State.normal)
        genderType = "male"
        doneClick()
    }

    @IBAction func femaleBtnAction(_: UIButton) {
        maleBtn.setImage(UIImage(named: "radio_inactive"), for: UIControl.State.normal)
        femaleBtn.setImage(UIImage(named: "radio_active"), for: UIControl.State.normal)
        genderType = "female"
        doneClick()
    }

    @IBAction func createAccountAction(_: UIButton) {
        self.view.endEditing(true)
        
        if termsBtn.tag == 1 {
            if Helper.sharedHelper.isNetworkAvailable() {
                let data1: NSData = UIImage(named: "user")!.pngData()! as NSData
                let data2: NSData = imageView.image!.pngData()! as NSData
                if data1 != data2 && editProfile != 0 && imageChanged {
                    Helper.sharedHelper.showGlobalHUD(title: "Posting...", view: view)
                    SDImageCache.shared().clearMemory()
                    SDImageCache.shared().clearDisk()
                    PWebService.sharedWebService.uploadImage(image: imageView.image!, imageName: PWebService.sharedWebService.currentUser?.email?.stringKey() ?? "", folderNamePath: kUSERS_T) { status, response, message in
                        
                        Helper.sharedHelper.dismissHUD(view: self.view)
                        
                        if status == 100 {
                            let str = NSString(format: "%@", response as! CVarArg)
                            self.uploadUserDetails(imageString: str as String)
                        } else {
                            Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
                        }
                    }
                } else {
                    uploadUserDetails(imageString: nil)
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

    func uploadUserDetails(imageString: String?) {
        if editProfile == 1 {
            fillDetial(imageString: imageString)
            upadateApi()
            return
        }
        var flag = false
        if APP_DELEGATE.fbUser == nil {
            if passwordTextField.text == confirmpasswordTextField.text {
                let count = passwordTextField.text?.count ?? 0
                if count > 5 {
                    flag = true
                } else {
                    Helper.sharedHelper.ShowAlert(str: "Password must be 6 charecter long or more", viewcontroller: self)
                }
            } else {
                Helper.sharedHelper.ShowAlert(str: "Password and confirm password isn't same", viewcontroller: self)
            }
        } else {
            flag = true
        }

        if flag == true {
            if Helper.sharedHelper.validateEmailWithString(emailTextField.text! as NSString) {
                if  !(userIdTextField.text ?? "").isEmpty && selectedInterestArr.count > 0 && !(firstnameTextField.text ?? "").isEmpty {
                    fillDetial(imageString: imageString)
                    callApi()
                } else {
                    Helper.sharedHelper.ShowAlert(str: "Please fill Name,User Id or Interest.", viewcontroller: self)
                }
            } else {
                Helper.sharedHelper.ShowAlert(str: "Enter valid email id", viewcontroller: self)
            }
        }
    }

    func fillDetial(imageString: String?) {
        if let str = imageString {
            signUpDict.setValue(str, forKey: "image_url")
        }
        let str = emailTextField.text!
        let replaced = str.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "@", with: "")
        
        signUpDict.setValue(firstnameTextField.text!, forKey: kFName)
        signUpDict.setValue((lastnameTextField.text ?? "").lowercased(), forKey: kLName)
        signUpDict.setValue(genderType, forKey: kGenderKey)
        signUpDict.setValue(genderTextField.text ?? "", forKey: kGenderOtherKey)
        signUpDict.setValue(firstNamePublic == true ? 1 : 0, forKey: kFirstNamePublicKey)
        
        
        signUpDict.setValue(0, forKey: "is_content_account_available")
        signUpDict.setValue(0, forKey: "is_news_account_available")
        signUpDict.setValue(0, forKey: "is_podcast_account_available")
        signUpDict.setValue(false, forKey: "is_authenticate_user")
        signUpDict.setValue("", forKey: "content_account_name")
        signUpDict.setValue(1, forKey: "name_public")
        signUpDict.setValue("", forKey: "news_site_name")
        signUpDict.setValue("", forKey: "podcast_account_name")
        signUpDict.setValue(replaced, forKey: "uid")
        signUpDict.setValue("", forKey: "worldwide_user_id")
        signUpDict.setValue(1, forKey: "email_public")
        signUpDict.setValue(1, forKey: "age_public")
        

        if editProfile == 0 {
            signUpDict.setValue(emailTextField.text!, forKey: kEmail)
            signUpDict.setValue(birtdateTF.text!, forKey: kBirthDate)
            signUpDict.setValue(false, forKey: kIsAuthenticateUser)
        }
        if selectedInterestArr.count > 0 {
            if !selectedInterestArr.contains("Selfie"){
                selectedInterestArr.append("Selfie")
            }
            signUpDict.setValue(selectedInterestArr, forKey: kInterest)
        }
        switch screenType {
        case .none:
            signUpDict.setValue(userIdTextField.text!, forKey: kUser_Id)
        case .home, .myProfileHome:
            signUpDict.setValue(userIdTextField.text!, forKey: kUser_Id)
        case .worldwide, .myProfileWorldwide:
            signUpDict.setValue(userIdTextField.text!, forKey: kWorldwideUserId)
        case .myProfileContentAccount:
            signUpDict.setValue(userIdTextField.text!, forKey: "content_account_name")
        case .myProfilePodcast:
            signUpDict.setValue(userIdTextField.text!, forKey: "podcast_account_name")
        case .myProfileNewsSite:
            signUpDict.setValue(userIdTextField.text!, forKey: "news_site_name")
        case .notes:
            break
        }

        if editProfile ==  0{
            signUpDict.setValue(passwordTextField.text!, forKey: kPasswordKey)
        }
    }

    func upadateApi() {
        Helper.sharedHelper.showGlobalHUD(title: "Updating profile...", view: view)

        PWebService.sharedWebService.webService(apiType: APIType.updateProfile, parameters: signUpDict as! [String: AnyObject]) { status, _, message in

            Helper.sharedHelper.dismissHUD(view: self.view)

            if status == 100 {
                Helper.sharedHelper.showGlobalAlertwithMessage(message!, vc: self, completion: {
                    self.navigationController?.popViewController(animated: true)

                })
            } else {
                Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
            }
        }
    }

    func callApi() {
        Helper.sharedHelper.showGlobalHUD(title: "Registering...", view: view)

        PWebService.sharedWebService.webService(apiType: APIType.signUpAccount, parameters: signUpDict as! [String: AnyObject]) { status, response, message in

            Helper.sharedHelper.dismissHUD(view: self.view)

            if status == 100 {
                if APP_DELEGATE.fbUser == nil {
                    userDefault.set(response![kEmail], forKey: kEmail)
                    userDefault.set(self.signUpDict, forKey: "loginDict")
                }

                let sb = UIStoryboard(name: "Main", bundle: nil)
                let tabBarController = sb.instantiateInitialViewController() as! UITabBarController
                let navVC = UINavigationController(rootViewController: tabBarController)
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = navVC
          
                 appDelegate.window?.makeKeyAndVisible()
                Auth.auth().currentUser?.sendEmailVerification { _ in
                }
            } else {
                Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
            }
        }
    }

    @IBAction func loginNowAction(_: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func dateTextFieldEditing(sender _: UITextField) {
        if editProfile == 0 {
            showDatePicker()
        }
    }

    @IBAction func interestTextFieldEditing(sender _: UIButton) {}

    @IBAction func interestBtnAction(_: UIButton) {
        let storyboard = UIStoryboard(name: "Shared", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: PInterestListViewController.identifier) as! PInterestListViewController
        vc.myDelegate = self
        vc.selectedInterests = selectedInterestArr
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func imagePickerBtnAxn(_ sender: UIButton) {
        if editProfile == 1 {
            let alert = UIAlertController(title: "Add a photo", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                    self.picker.sourceType = UIImagePickerController.SourceType.camera
                    // picker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
                    self.present(self.picker, animated: true, completion: nil)
                } else {
                    Helper.sharedHelper.showGlobalAlertwithMessage("Camera is not exist.", vc: self)
                }
            }))

            alert.addAction(UIAlertAction(title: "Gallary", style: .default, handler: { _ in
                self.picker.sourceType = UIImagePickerController.SourceType.photoLibrary
                // picker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
                self.present(self.picker, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceRect = sender.bounds
                popoverController.sourceView = sender
            }
            present(alert, animated: true, completion: nil)
        }
    }

    func showDatePicker() {
        // Formate Date
        let date = Calendar.current.date(byAdding: .year, value: -18, to: Date())
        datePicker.datePickerMode = .date
        datePicker.maximumDate = date
        datePicker.date = date ?? Date()
        // ToolBar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker))

        toolbar.setItems([doneButton, spaceButton, cancelButton], animated: false)

        birtdateTF.inputAccessoryView = toolbar
        birtdateTF.inputView = datePicker
    }

    @objc func donedatePicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        birtdateTF.text = formatter.string(from: datePicker.date)
        view.endEditing(true)
    }

    @objc func cancelDatePicker() {
        view.endEditing(true)
    }

    @objc func pickUp() {
        // UIPickerView
        myPickerView = UIPickerView(frame: CGRect(x: 0, y: view.frame.size.height - 200, width: view.frame.size.width, height: 200))
        myPickerView?.delegate = self
        myPickerView?.dataSource = self
        myPickerView?.backgroundColor = UIColor.white
        // ToolBar
        toolBar = UIToolbar(frame: CGRect(x: 0, y: view.frame.size.height - 220, width: view.frame.size.width, height: 20))
        toolBar?.barStyle = .default
        toolBar?.isTranslucent = true
        toolBar?.tintColor = UIColor(red: 92 / 255, green: 216 / 255, blue: 255 / 255, alpha: 1)
        toolBar?.sizeToFit()

        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
        toolBar?.setItems([doneButton], animated: false)
        toolBar?.isUserInteractionEnabled = true
        genderTextField.inputView = myPickerView
        genderTextField.inputAccessoryView = toolBar
    }

    // MARK: - Picker Button

    @objc func doneClick() {
        myPickerView?.removeFromSuperview()
        toolBar?.removeFromSuperview()
        genderTextField.resignFirstResponder()
    }
}

// MARK: - UIPickerViewDelegate Methods

extension PRegistrationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: - PickerView Delegate & DataSource

    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return genderData.count
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        return genderData[row]
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        maleBtn.setImage(UIImage(named: "radio_inactive"), for: UIControl.State.normal)
        femaleBtn.setImage(UIImage(named: "radio_inactive"), for: UIControl.State.normal)
        genderType = genderData[row]
        genderTextField.text = genderData[row]
    }
}

// MARK: - UIImagePickerControllerDelegate Methods

extension PRegistrationViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            imageChanged = true
            picker.dismiss(animated: true, completion: nil)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension PRegistrationViewController: IntersetsListDelegate {
    func selectedInterestArr(arr: [String]) {
        selectedInterestArr = arr
        interestHeightConstant.constant = 14
        interestView.reloadData()
    }
}

extension PRegistrationViewController: ZFTokenFieldDelegate, ZFTokenFieldDataSource {
    func tokenMarginInToken(in _: ZFTokenField!) -> CGFloat {
        return marginLbl
    }

    func lineHeightForToken(in _: ZFTokenField!) -> CGFloat {
        return tokenHeight
    }

    func numberOfToken(in _: ZFTokenField!) -> UInt {
        if selectedInterestArr.count < 10 {
            interestViewHeight.constant = 70
        } else {
            interestViewHeight.constant = 104
        }
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
        testLbl1.backgroundColor = MainCgColor
        testLbl1.textColor = UIColor.white

        testLbl1.clipsToBounds = true

        return testLbl1
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
