//
//  PCreateNotesViewController.swift
//  Peps
//
//  Created by sivaprasad reddy on 30/06/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import CoreLocation
import GSMessages
import UIKit

class PCreateNotesViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {
    @IBOutlet var postNotesBtn: UIButton!
    @IBOutlet var noBtn: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var yesBtn: UIButton!
    @IBOutlet var noteTextView: UITextView!
    @IBOutlet var seekingTextFiled: UITextField!
    @IBOutlet var distanceTextField: UITextField!
    @IBOutlet var ageTextField: UITextField!
    @IBOutlet weak var whoCanSeeGenderTF: UITextField!
    @IBOutlet weak var whoCanSeeAgeTF:UITextField!
    @IBOutlet var fromTextField: UITextField!
    @IBOutlet var lookingForTextField: UITextField!
    @IBOutlet var iamTextField: UITextField!
    @IBOutlet var allowOtherNoBtn: UIButton!
    @IBOutlet var allowOtherYesBtn: UIButton!
    var distancePicker = UIPickerView()
    var lookingForPicker = UIPickerView()
    var whoCanSeeGenderPicker = UIPickerView()
    var whoCanSeeAgePicker = UIPickerView()
    var iAmPicker = UIPickerView()
    var distanceArr = ["3", "5", "7", "10"]
    var ageGroupArr = ["0-8", "8-18", "18-28", "28-38", "38-48" , "48-58" , "58-68" , "68+"]
    var lookingforArr = ["Friend", "Date", "Chat", "Casual"]
    var iAmArr = ["Male", "Female", "Agender", "Androgyne", "Androgynous", "Bigender", "Cis", "Cisgender", "Cis Female", "Cis Male", "Cis Man", "Cis Woman", "Cisgender Female", "Cisgender Male", "Cisgender Man", "Cisgender Woman", "Female to Male", "FTM", "Gender Fluid", "Gender Nonconforming", "Gender Questioning", "Gender Variant", "Genderqueer", "Intersex"]
    var picker = UIImagePickerController()
    var locationManager = CLLocationManager()
    var radioBut = true
    var allowOtherRadioBut = 1
    var editNotesObj: PNotesModel?
    var editPost = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Create Notes"

        distancePicker = UIPickerView()
        distancePicker.delegate = self
        distancePicker.dataSource = self
        distancePicker.backgroundColor = UIColor.white
        distanceTextField.inputView = distancePicker

        lookingForPicker = UIPickerView()
        lookingForPicker.delegate = self
        lookingForPicker.dataSource = self
        lookingForPicker.backgroundColor = UIColor.white
        lookingForTextField.inputView = lookingForPicker

        iAmPicker = UIPickerView()
        iAmPicker.delegate = self
        iAmPicker.dataSource = self
        iAmPicker.backgroundColor = UIColor.white
        iamTextField.inputView = iAmPicker
        seekingTextFiled.inputView = iAmPicker
        whoCanSeeGenderTF.inputView = iAmPicker
        
        whoCanSeeAgePicker = UIPickerView()
        whoCanSeeAgePicker.delegate = self
        whoCanSeeAgePicker.dataSource = self
        whoCanSeeAgePicker.backgroundColor = UIColor.white
        whoCanSeeAgeTF.inputView = whoCanSeeAgePicker
        
        picker.delegate = self

        iamTextField.text = PWebService.sharedWebService.currentUser?.gender
        ageTextField.text = "\(calcAge(birthday: (PWebService.sharedWebService.currentUser?.date_of_birth ?? "")!))"

        yesBtn.setImage(UIImage(named: "radio_active"), for: UIControl.State.normal)
        noBtn.setImage(UIImage(named: "radio_inactive"), for: UIControl.State.normal)
        allowOtherNoBtn.setImage(UIImage(named: "radio_inactive"), for: UIControl.State.normal)
        allowOtherYesBtn.setImage(UIImage(named: "radio_active"), for: UIControl.State.normal)
        if editPost == 1 {
            fromTextField.text = editNotesObj?.notesFrom
            ageTextField.text = "\(editNotesObj?.age ?? 0)"
            iamTextField.text = editNotesObj?.iAm
            lookingForTextField.text = editNotesObj?.lookingFor
            distanceTextField.text = "\(editNotesObj?.distance ?? 0)"
            seekingTextFiled.text = editNotesObj?.seeking
            noteTextView.text = editNotesObj?.notes
            self.whoCanSeeGenderTF.text =  editNotesObj?.whocanseegender
            self.whoCanSeeAgeTF.text = editNotesObj?.whocanseeage
            postNotesBtn.setTitle("Update Notes", for: .normal)
            if let urlStr = editNotesObj!.imageUrl {
                imageView.sd_setImage(with: URL(string: urlStr), placeholderImage: UIImage(named: "image_placeholder"))
            } else {
                imageView.image = #imageLiteral(resourceName: "image_placeholder")
            }
        }
    }

    func calcAge(birthday: String) -> Int {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "dd/MM/yyyy"
        let birthdayDate = dateFormater.date(from: birthday)
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
        let now = Date()
        let calcAge = calendar.components(.year, from: birthdayDate!, to: now, options: [])
        let age = calcAge.year
        return age!
    }

    @IBAction func imageSelectBtnAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select The Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                self.picker.sourceType = UIImagePickerController.SourceType.camera
                // picker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
                // self.imageSelectionType = .selfie
                self.present(self.picker, animated: true, completion: nil)
            } else {
                Helper.sharedHelper.showGlobalAlertwithMessage("Camera is not exist.", vc: self)
            }
        }))
        alert.addAction(UIAlertAction(title: "Gallary", style: .default, handler: { _ in
            self.picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            // picker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
            // self.imageSelectionType = .selfie
            self.present(self.picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceRect = sender.bounds
            popoverController.sourceView = sender
        }
        present(alert, animated: true, completion: nil)
    }

    @IBAction func responderBtnAction(_ sender: UIButton) {
        if sender.tag == 1 {
            yesBtn.setImage(UIImage(named: "radio_active"), for: UIControl.State.normal)
            noBtn.setImage(UIImage(named: "radio_inactive"), for: UIControl.State.normal)
            radioBut = true
        } else {
            noBtn.setImage(UIImage(named: "radio_active"), for: UIControl.State.normal)
            yesBtn.setImage(UIImage(named: "radio_inactive"), for: UIControl.State.normal)
            radioBut = false
        }
    }
    
    @IBAction func allowOtherBtnAction(_ sender: UIButton) {
        if sender.tag == 1 {
            allowOtherYesBtn.setImage(UIImage(named: "radio_active"), for: UIControl.State.normal)
            allowOtherNoBtn.setImage(UIImage(named: "radio_inactive"), for: UIControl.State.normal)
            allowOtherRadioBut = 1
        } else {
            allowOtherNoBtn.setImage(UIImage(named: "radio_active"), for: UIControl.State.normal)
            allowOtherYesBtn.setImage(UIImage(named: "radio_inactive"), for: UIControl.State.normal)
            allowOtherRadioBut = 0
        }
    }
    
    @IBAction func postNoteBtnAction(_: UIButton) {
        if editPost == 1 {
            updatePost()
            return
        }

        guard fromTextField.text != "" else {
            Helper.sharedHelper.showGlobalAlertwithMessage("Please enter the from address.", vc: self)
            return
        }

        guard lookingForTextField.text != "" else {
            Helper.sharedHelper.showGlobalAlertwithMessage("Please select the whome your looking.", vc: self)
            return
        }

        guard distanceTextField.text != "" else {
            Helper.sharedHelper.showGlobalAlertwithMessage("Please select the nearrer distance.", vc: self)
            return
        }

        guard seekingTextFiled.text != "" else {
            Helper.sharedHelper.showGlobalAlertwithMessage("Please select the seeking for.", vc: self)
            return
        }
        guard whoCanSeeAgeTF.text != "" else {
            Helper.sharedHelper.showGlobalAlertwithMessage("Please select the who can see.", vc: self)
            return
        }
        guard whoCanSeeGenderTF.text != "" else {
            Helper.sharedHelper.showGlobalAlertwithMessage("Please select the who can see.", vc: self)
            return
        }

        guard noteTextView.text != "" && noteTextView.text != "What is in your mind?" else {
            Helper.sharedHelper.showGlobalAlertwithMessage("Please enter the notes.", vc: self)
            return
        }

        let data1: NSData = UIImage(named: "image_placeholder")!.pngData()! as NSData
        let data2: NSData = imageView.image!.pngData()! as NSData
        if data1 != data2 {
            uploadPostWithImage()
        } else {
            uploadNotes(imageString: "")
        }
    }

    // MARK: - API Call Methods

    func uploadPostWithImage() {
        Helper.sharedHelper.showGlobalHUD(title: "Posting...", view: view)

        PWebService.sharedWebService.uploadImage(image: imageView.image!, imageName: Helper.sharedHelper.generateName(), folderNamePath: kUSER_NOTES_T) { status, response, message in

            Helper.sharedHelper.dismissHUD(view: self.view)

            if status == 100 {
                let str = NSString(format: "%@", response as! CVarArg)
                self.uploadNotes(imageString: str as String)
            } else {
                Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
            }
        }
    }

    func uploadNotes(imageString: String) {
        let loginDict = NSMutableDictionary()
        loginDict.setValue(imageString, forKey: "imageUrl")
        loginDict.setValue(fromTextField.text, forKey: "notesFrom")
        loginDict.setValue(ageTextField.text, forKey: "age")
        loginDict.setValue(iamTextField.text, forKey: "iAm")
        loginDict.setValue(lookingForTextField.text, forKey: "lookingFor")
        loginDict.setValue(Int(distanceTextField.text!), forKey: "distance")
        loginDict.setValue(seekingTextFiled.text, forKey: "seeking")
        loginDict.setValue(noteTextView.text, forKey: "notes")
        loginDict.setValue(PWebService.sharedWebService.currentUser?.email!, forKey: "userKey")
        loginDict.setValue(radioBut, forKey: "respondWithPic")
        loginDict.setValue(allowOtherRadioBut, forKey: "allowOther")
        loginDict.setValue(self.whoCanSeeGenderTF.text, forKey: "whocanseegender")
        loginDict.setValue(self.whoCanSeeAgeTF.text, forKey: "whocanseeage")
        
//        loginDict.setValue(postObj?.row_Key, forKey: "row_key")
        let disc = NSMutableDictionary()
        disc.setValue(locationManager.location?.coordinate.longitude, forKey: "lng")
        disc.setValue(locationManager.location?.coordinate.latitude, forKey: "lat")
        loginDict.setValue(disc, forKey: "userLocation")

        PWebService.sharedWebService.createNewTable(apiType: kUSER_NOTES_T, parameters: loginDict as! [String: AnyObject], completion: { status, _, message in

            if status == 100 {
                self.showMessage(message ?? "Done", type: .success)
                self.navigationController?.popViewController(animated: true)
            } else {
                Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
            }
        })
    }

    func updatePost() {
        Helper.sharedHelper.showGlobalHUD(title: "Updating...", view: view)

        PWebService.sharedWebService.uploadImage(image: imageView.image!, imageName: Helper.sharedHelper.generateName(), folderNamePath: kUSER_NOTES_T) { status, response, message in

            Helper.sharedHelper.dismissHUD(view: self.view)

            if status == 100 {
                let str = NSString(format: "%@", response as! CVarArg)
                let loginDict = NSMutableDictionary()
                loginDict.setValue(str, forKey: "imageUrl")
                loginDict.setValue(self.fromTextField.text, forKey: "notesFrom")
                loginDict.setValue(self.ageTextField.text, forKey: "age")
                loginDict.setValue(self.iamTextField.text, forKey: "iAm")
                loginDict.setValue(self.lookingForTextField.text, forKey: "lookingFor")
                loginDict.setValue(Int(self.distanceTextField.text!), forKey: "distance")
                loginDict.setValue(self.seekingTextFiled.text, forKey: "seeking")
                loginDict.setValue(self.noteTextView.text, forKey: "notes")
                loginDict.setValue(PWebService.sharedWebService.currentUser?.email!, forKey: "userKey")
                loginDict.setValue(self.radioBut, forKey: "respondWithPic")
                loginDict.setValue(self.whoCanSeeGenderTF.text, forKey: "whocanseegender")
                loginDict.setValue(self.whoCanSeeAgeTF.text, forKey: "whocanseeage")
                let disc = NSMutableDictionary()
                disc.setValue(self.locationManager.location?.coordinate.longitude, forKey: "lng")
                disc.setValue(self.locationManager.location?.coordinate.latitude, forKey: "lat")
                loginDict.setValue(disc, forKey: "userLocation")

                PWebService.sharedWebService.updatePost(parameters: loginDict as! [String: AnyObject],
                                                        rowKey: self.editNotesObj!.row_key!,
                                                        childName: kUSER_NOTES_T,
                                                        completion: { status, _, message in

                                                            if status == 100 {
                                                                Helper.sharedHelper.showGlobalAlertwithMessage(message!, vc: self, completion: {
                                                                    self.navigationController?.popViewController(animated: true)

                                                                })
                                                            } else {
                                                                Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
                                                            }
                })
            } else {
                Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
            }
        }
    }

    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        if lookingForPicker == pickerView {
            if lookingForTextField.text?.isEmpty ?? false{
                lookingForTextField.text = lookingforArr[0]
            }
            return lookingforArr.count
        } else if iAmPicker == pickerView {
            if iamTextField.text?.isEmpty ?? false && iamTextField.isEditing{
                iamTextField.text = iAmArr[0]
            }
            else if seekingTextFiled.text?.isEmpty ?? false && seekingTextFiled.isEditing{
                seekingTextFiled.text = iAmArr[0]
            }
            else if whoCanSeeGenderTF.text?.isEmpty ?? false && whoCanSeeGenderTF.isEditing{
                whoCanSeeGenderTF.text = iAmArr[0]
            }
            return iAmArr.count
        } else if whoCanSeeAgePicker == pickerView{
            if whoCanSeeAgeTF.text?.isEmpty ?? false{
                whoCanSeeAgeTF.text = ageGroupArr[0]
            }
            return ageGroupArr.count
        }else {
            if distanceTextField.text?.isEmpty ?? false{
                distanceTextField.text = distanceArr[0]
            }
            return distanceArr.count
        }
        
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        if lookingForPicker == pickerView {
            return lookingforArr[row]
        } else if iAmPicker == pickerView {
            return iAmArr[row]
        }  else if whoCanSeeAgePicker == pickerView{
                   return ageGroupArr[row]
        } else {
            return distanceArr[row]
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        if lookingForPicker == pickerView {
            lookingForTextField.text = lookingforArr[row]
        } else if iAmPicker == pickerView && iamTextField.isEditing {
            iamTextField.text = iAmArr[row]
        } else if iAmPicker == pickerView && seekingTextFiled.isEditing {
            seekingTextFiled.text = iAmArr[row]
        } else if iAmPicker == pickerView && whoCanSeeGenderTF.isEditing {
            whoCanSeeGenderTF.text = iAmArr[row]
        } else if whoCanSeeAgePicker == pickerView{
            whoCanSeeAgeTF.text = ageGroupArr[row]
        }else {
            distanceTextField.text = distanceArr[row]
        }
    }
    

    // MARK: - UIImagePickerControllerDelegate Methods

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            picker.dismiss(animated: true, completion: nil)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    // MARK: - UITextViewDelegate Methods

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == noteTextView && textView.text == "What is in your mind?" {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == noteTextView && textView.text == "" {
            textView.text = "What is in your mind?"
            textView.textColor = UIColor.lightGray
        }
    }
}
