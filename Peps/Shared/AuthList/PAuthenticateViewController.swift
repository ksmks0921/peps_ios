//
//  PAuthenticateViewController.swift
//  Peps
//
//  Created by Shubham Garg on 17/05/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import Photos
import SimpleImageViewer
import UIKit

class PAuthenticateViewController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet var firstnameTextField: UITextField!
    @IBOutlet var submitBtn: UIButton!
    @IBOutlet var lastnameTextField: UITextField!
    @IBOutlet var uploadSelfieIDBtn: UIButton!
    @IBOutlet var uploadSelfieIDView: UIView!
    @IBOutlet var uploadFrontIDBtn: UIButton!
    @IBOutlet var uploadFrontIDView: UIView!
    @IBOutlet var uploadBackIDBtn: UIButton!
    @IBOutlet var uploadBackIDView: UIView!
    @IBOutlet var birtdateTF: UITextField!
    @IBOutlet var selfieImageView: UIImageView!
    @IBOutlet var frontIMageView: UIImageView!
    @IBOutlet var backIMageView: UIImageView!
    @IBOutlet var worldwideIdTextField: UITextField!
    @IBOutlet var commentTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: UIView!

    var authData: AuthData?
    var comments: [PComments]?
    var userKey = PWebService.sharedWebService.userKey
    var picker = UIImagePickerController()
    let datePicker = UIDatePicker()
    var imageSelectionType: ImageSelectionType = .selfie
    var images: (selfie: UIImage?, front: UIImage?, back: UIImage?) = (selfie: nil, front: nil, back: nil)

    enum ImageSelectionType {
        case selfie, front, back
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Fetch record
        if isAdminApp {
            firstnameTextField.isEnabled = false
            lastnameTextField.isEnabled = false
            birtdateTF.isEnabled = false
            worldwideIdTextField.isEnabled = false
            uploadFrontIDBtn.setTitle("", for: .normal)
            uploadBackIDBtn.setTitle("", for: .normal)
            uploadSelfieIDBtn.setTitle("", for: .normal)
            submitBtn.setTitle("Approve", for: .normal)
            title = "WorldWide"
        }

        picker.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        fetchRecord()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.keyboardWillHide))
        view.addGestureRecognizer(tap)
        headerView.layer.borderColor = UIColor.lightGray.cgColor
        headerView.layer.borderWidth = 0.5
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Helper.sharedHelper.setDottedBorder(view: selfieImageView)
        Helper.sharedHelper.setDottedBorder(view: frontIMageView)
        Helper.sharedHelper.setDottedBorder(view: backIMageView)
        parent?.title = "WorldWide"
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func renderData() {
        guard let authData = self.authData else {
            return
        }
        firstnameTextField.text = authData.first_name
        lastnameTextField.text = authData.last_name
        birtdateTF.text = authData.date_of_birth
        worldwideIdTextField.text = authData.worldwide_user_id

        if let url = authData.selfie_id {
            selfieImageView.sd_setImage(with: URL(string: url), completed: { _, error, _, _ in
                if error == nil {
                    self.images.selfie = self.selfieImageView.image
                }
            })
        }
        if let url = authData.front_id {
            frontIMageView.sd_setImage(with: URL(string: url), completed: { _, error, _, _ in
                if error == nil {
                    self.images.front = self.frontIMageView.image
                }
            })
        }
        if let url = authData.back_id {
            backIMageView.sd_setImage(with: URL(string: url), completed: { _, error, _, _ in
                if error == nil {
                    self.images.back = self.backIMageView.image
                }
            })
        }
    }

    func fetchRecord() {
        PWebService.sharedWebService.fetchAuthData(userKey: userKey) { _, response, _ in
            if let response = response as? NSDictionary {
                self.authData = AuthData(dictionary: response)
                self.comments = self.authData?.comments
                self.renderData()
                self.tableView.reloadData()
            }
        }
    }

    @IBAction func dateTextFieldEditing(sender _: UITextField) {
        showDatePicker()
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

    @IBAction func selfieImagePickerBtnAxn(_ sender: UIButton) {
        if isAdminApp {
            let configuration = ImageViewerConfiguration { config in
                config.imageView = selfieImageView
            }
            present(ImageViewerController(configuration: configuration), animated: true)
        } else {
            let alert = UIAlertController(title: "Upload selfie page of Id", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                    self.picker.sourceType = UIImagePickerController.SourceType.camera
                    // picker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
                    self.imageSelectionType = .selfie
                    self.present(self.picker, animated: true, completion: nil)
                } else {
                    Helper.sharedHelper.showGlobalAlertwithMessage("Camera is not exist.", vc: self)
                }
            }))
            alert.addAction(UIAlertAction(title: "Gallary", style: .default, handler: { _ in
                self.picker.sourceType = UIImagePickerController.SourceType.photoLibrary
                // picker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
                self.imageSelectionType = .selfie
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

    @IBAction func frontImagePickerBtnAxn(_ sender: UIButton) {
        if isAdminApp {
            let configuration = ImageViewerConfiguration { config in
                config.imageView = frontIMageView
            }
            present(ImageViewerController(configuration: configuration), animated: true)
        } else {
            let alert = UIAlertController(title: "Upload front page of Id", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                    self.picker.sourceType = UIImagePickerController.SourceType.camera
                    // picker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
                    self.imageSelectionType = .front
                    self.present(self.picker, animated: true, completion: nil)
                } else {
                    Helper.sharedHelper.showGlobalAlertwithMessage("Camera is not exist.", vc: self)
                }
            }))
            alert.addAction(UIAlertAction(title: "Gallary", style: .default, handler: { _ in
                self.picker.sourceType = UIImagePickerController.SourceType.photoLibrary
                // picker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
                self.imageSelectionType = .front
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

    @IBAction func backImagePickerBtnAxn(_ sender: UIButton) {
        if isAdminApp {
            let configuration = ImageViewerConfiguration { config in
                config.imageView = backIMageView
            }
            present(ImageViewerController(configuration: configuration), animated: true)
        } else {
            let alert = UIAlertController(title: "Upload back page of Id", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                    self.picker.sourceType = UIImagePickerController.SourceType.camera
                    // picker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
                    self.imageSelectionType = .back
                    self.present(self.picker, animated: true, completion: nil)
                } else {
                    Helper.sharedHelper.showGlobalAlertwithMessage("Camera is not exist.", vc: self)
                }
            }))
            alert.addAction(UIAlertAction(title: "Gallary", style: .default, handler: { _ in
                self.picker.sourceType = UIImagePickerController.SourceType.photoLibrary
                // picker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
                self.imageSelectionType = .back
                self.present(self.picker, animated: true, completion: nil)
            }))
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceRect = sender.bounds
                popoverController.sourceView = sender
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func submitBtnAxn(_: Any) {
        if isAdminApp {
            if let finalData = authData?.dictionaryRepresentation() as? [String: AnyObject] {
                PWebService.sharedWebService.authenticateUser(parameters: finalData, userKey: userKey) { _, _, _ in
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            if images.selfie == nil {
                Helper.sharedHelper.ShowAlert(str: "Please upload a selfie Photo of Id.", viewcontroller: self)
                return
            }
            if images.front == nil {
                Helper.sharedHelper.ShowAlert(str: "Please upload a front Photo of Id.", viewcontroller: self)
                return
            }
            if images.back == nil {
                Helper.sharedHelper.ShowAlert(str: "Please upload a back Photo of Id.", viewcontroller: self)
                return
            }
            if worldwideIdTextField.text?.replacingOccurrences(of: "", with: " ") == "" {
                Helper.sharedHelper.ShowAlert(str: "Please enter a Worldwide Id.", viewcontroller: self)
                return
            }

            uploadId()
        }
    }

    func uploadId() {
        Helper.sharedHelper.showGlobalHUD(title: "Posting...", view: view)
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
        PWebService.sharedWebService.uploadImage(image: images.selfie!, imageName: userKey + "SelfieID", folderNamePath: kWORLDWIDE_REQUEST_LIST_T) { status, response, message in

            Helper.sharedHelper.dismissHUD(view: self.view)

            if status == 100 {
                let selfieImageStr = NSString(format: "%@", response as! CVarArg)
                Helper.sharedHelper.showGlobalHUD(title: "Uploading Selfie ID ...", view: self.view)
                PWebService.sharedWebService.uploadImage(image: self.images.front!, imageName: self.userKey + "FrontID", folderNamePath: kWORLDWIDE_REQUEST_LIST_T) { status, response, message in

                    Helper.sharedHelper.dismissHUD(view: self.view)

                    if status == 100 {
                        let frontImageStr = NSString(format: "%@", response as! CVarArg)
                        Helper.sharedHelper.showGlobalHUD(title: "Uploading Front ID ...", view: self.view)
                        PWebService.sharedWebService.uploadImage(image: self.images.back!, imageName: self.userKey + "BackID", folderNamePath: kWORLDWIDE_REQUEST_LIST_T) { status, response, message in

                            Helper.sharedHelper.dismissHUD(view: self.view)

                            if status == 100 {
                                let backImageStr = NSString(format: "%@", response as! CVarArg)

                                let authenticateDict = NSMutableDictionary()
                                authenticateDict.setValue(selfieImageStr, forKey: "selfie_id")
                                authenticateDict.setValue(frontImageStr, forKey: "front_id")
                                authenticateDict.setValue(backImageStr, forKey: "back_id")
                                authenticateDict.setValue(0, forKey: kStatus)
                                authenticateDict.setValue(self.firstnameTextField.text!, forKey: kFName)
                                authenticateDict.setValue(self.lastnameTextField.text!, forKey: kLName)
                                authenticateDict.setValue(PWebService.sharedWebService.currentUser?.email!, forKey: kEmail)
                                authenticateDict.setValue(PWebService.sharedWebService.userKey, forKey: "row_key")
                                authenticateDict.setValue(self.birtdateTF.text!, forKey: kBirthDate)
                                authenticateDict.setValue(false, forKey: kIsAuthenticateUser)
                                authenticateDict.setValue(self.worldwideIdTextField.text ?? "", forKey:
                                    kWorldwideUserId)
                                Helper.sharedHelper.showGlobalHUD(title: "Uploading Back ID ...", view: self.view)

                                PWebService.sharedWebService.webService(apiType: APIType.authUpdateProfile,
                                                                        parameters: authenticateDict as! [String: AnyObject]) { status, _, message in

                                    Helper.sharedHelper.dismissHUD(view: self.view)

                                    if status == 100 {
                                        Helper.sharedHelper.showGlobalAlertwithMessage("Authentication request submitted.", vc: self, completion: {
                                            self.navigationController?.popViewController(animated: true)

                                        })
                                    } else {
                                        Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
                                    }
                                }
                            } else {
                                Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
                            }
                        }
                    } else {
                        Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
                    }
                }
            } else {
                Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
           view.endEditing(true)
       }
}

// MARK: - UIImagePickerControllerDelegate Methods

extension PAuthenticateViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if let data = image.jpegData(compressionQuality: 1.0) {
                // Here you get MB size
                let size = Float(Double(data.count) / 1024 / 1024)

                if size > 15.00 {
                    picker.dismiss(animated: true, completion: nil)
                    Helper.sharedHelper.ShowAlert(str: "Image Size can't be more than 15 MB.", viewcontroller: self)

                    return
                }
            }
            if imageSelectionType == .selfie {
                selfieImageView.contentMode = .scaleAspectFit
                selfieImageView.image = image

                images.selfie = image
            } else if imageSelectionType == .front {
                frontIMageView.contentMode = .scaleAspectFit
                frontIMageView.image = image

                images.front = image
            } else {
                backIMageView.contentMode = .scaleAspectFit
                backIMageView.image = image

                images.back = image
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    @IBAction func sendCommentAction(_: UIButton) {
        if let text = commentTextField.text {
            guard let user = PWebService.sharedWebService.currentUser else {
                return
            }
            Helper.sharedHelper.showGlobalHUD(title: "Posting...", view: view)
            let commentsdict = NSMutableDictionary()
            commentsdict.setValue(text, forKey: "comment_text")
            commentsdict.setValue(user.full_name, forKey: "user_name")
            commentsdict.setValue(user.email, forKey: kEmail)
            commentsdict.setValue(user.image_url, forKey: "profile_url")
            commentsdict.setValue(user.user_id, forKey: kUser_Id)
            PWebService.sharedWebService.addCommentAuth(parameters: commentsdict as! [String: AnyObject],
                                                        receiverEmail: userKey,
                                                        completion: { _, _, _ in
                                                            Helper.sharedHelper.dismissHUD(view: self.view)
                                                            self.commentTextField.text = ""
                                                            // Fetch comments
                                                            self.fetchRecord()

            })
        }
    }
}

extension PAuthenticateViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let comment = comments?[indexPath.row]
        cell?.textLabel?.text = comment?.user_name
        cell?.detailTextLabel?.text = comment?.comment_text
        return cell!
    }

    func numberOfSections(in _: UITableView) -> Int {
        if comments?.count == 0 {
            return 0
        }
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return comments?.count ?? 0
    }

    func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        if PWebService.sharedWebService.currentUser?.is_worldwide_available != nil || isAdminApp {
            return headerView
        } else {
            return UIView(frame: .zero)
        }
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 50
    }
}
