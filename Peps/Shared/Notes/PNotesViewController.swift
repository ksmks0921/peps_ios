//
//  PNotesViewController.swift
//  Peps
//
//  Created by sivaprasad reddy on 30/06/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import CoreLocation
import SimpleImageViewer
import UIKit

class PNotesViewController: UIViewController, UISearchBarDelegate {
    var notesArr = [PNotesModel]()
    @IBOutlet var tableview: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var postNotesBtnHeight:NSLayoutConstraint!
    var filteredArray = [PNotesModel]()
    var searchActive: Bool = false
    var screenType = 0
    let locationManager = CLLocationManager()
    var selectedGenderArr:[String] = []
    var selectedinterestArr:[String] = [] 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parent?.title = "Come2Gether"
        let image = UIImage(named: "filter")
        let renderedImage = image?.withRenderingMode(.alwaysOriginal)
        let filterButton = UIBarButtonItem(image: renderedImage!, style: .plain,target: self, action: #selector(self.filterBtnAction))
        parent?.navigationItem.setRightBarButton(filterButton, animated: true)
        locationFetching()
        
        if screenType == 1 {
            getMyNotesList()
            postNotesBtnHeight.constant = 0
        } else {
            getNotesList()
            postNotesBtnHeight.constant = 44
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        parent?.navigationItem.setRightBarButton(nil, animated: false)
    }
    
    func getNotesList() {
        Helper.sharedHelper.showGlobalHUD(title: "", view: view)
        if Helper.sharedHelper.isNetworkAvailable() {
            PWebService.sharedWebService.fetchRecord(childName: kUSER_NOTES_T,
                                                     queryChildName: nil, queryValue: nil,
                                                     completion: { _, response, _ in
                                                        Helper.sharedHelper.dismissHUD(view: self.view)
                                                        let arr = PNotesModel.modelsFromDictionaryArray(array: response as! NSArray)
                                                        let dummyArr = NSMutableArray()
                                                        if let lat = self.locationManager.location?.coordinate.latitude, let long = self.locationManager.location?.coordinate.longitude{
                                                            for objc in arr {
                                                                let myLocation = CLLocation(latitude: lat, longitude: long)
                                                                let notesLocation = CLLocation(latitude: objc.userLocation?["lat"] as?  CLLocationDegrees ?? 0, longitude: objc.userLocation?["lng"] as? CLLocationDegrees ?? 0)
                                                                let distance = myLocation.distance(from: notesLocation) / 1000
                                                                
                                                                //                                                             print(distance)
                                                                if distance <= 10.0  && objc.whocanseegender == PWebService.sharedWebService.currentUser?.gender?.capitalized{
                                                                    if (self.selectedGenderArr.count > 0 && self.selectedGenderArr.contains(objc.seeking?.capitalized ?? "")) || (self.selectedinterestArr.count > 0 && self.selectedinterestArr.contains(objc.lookingFor?.capitalized ?? "")){
                                                                        dummyArr.add(objc)
                                                                    }
                                                                    else if self.selectedGenderArr.count == 0 && self.selectedinterestArr.count == 0{
                                                                        dummyArr.add(objc)
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        
                                                        
                                                        self.notesArr = dummyArr as! [PNotesModel]
                                                        self.tableview.reloadData()
            })
        } else {
            DispatchQueue.main.async {
                Helper.sharedHelper.ShowAlert(str: "No Internet Connection", viewcontroller: self)
                Helper.sharedHelper.dismissHUD(view: self.view)
            }
        }
    }
    
    func getMyNotesList() {
        Helper.sharedHelper.showGlobalHUD(title: "", view: view)
        if Helper.sharedHelper.isNetworkAvailable() {
            PWebService.sharedWebService.fetchRecord(childName: kUSER_NOTES_T,
                                                     queryChildName: "userKey", queryValue: (PWebService.sharedWebService.currentUser?.email ?? "") as AnyObject,
                                                     completion: { _, response, _ in
                                                        Helper.sharedHelper.dismissHUD(view: self.view)
                                                        let arr = PNotesModel.modelsFromDictionaryArray(array: response as! NSArray)
                                                        self.notesArr = arr as [PNotesModel]
                                                        self.tableview.reloadData()
            })
        } else {
            DispatchQueue.main.async {
                Helper.sharedHelper.ShowAlert(str: "No Internet Connection", viewcontroller: self)
                Helper.sharedHelper.dismissHUD(view: self.view)
            }
        }
    }
    
    @IBAction func postNoteBtnAction(_: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: PCreateNotesViewController.identifier) as! PCreateNotesViewController
        vc.locationManager = locationManager
        navigationController?.pushViewController(vc, animated: true)
    }
    
   
    
    func btnEditClick(postDetails: PNotesModel) {
        let vc = storyboard?.instantiateViewController(withIdentifier: PCreateNotesViewController.identifier) as! PCreateNotesViewController
        vc.editPost = 1
        vc.editNotesObj = postDetails
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func btnDeleteClick(postDetails: PNotesModel) {
        let alertController = UIAlertController(title: "Alert", message: "Are you sure, you want to delete this post?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (_: UIAlertAction!) in
            Helper.sharedHelper.showGlobalHUD(title: "Deleting post..", view: self.view)
            PWebService.sharedWebService.removePost(rowKey: postDetails.row_key!, childName: kUSER_NOTES_T, completion: { status, _, message in
                
                Helper.sharedHelper.dismissHUD(view: self.view)
                if status == 100 {
                    Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
                    self.getNotesList()
                }
            })
        }))
        alertController.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func filterBtnAction(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: PNotesFilterViewController.identifier) as! PNotesFilterViewController
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension PNotesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }
    
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if searchActive {
            return filteredArray.count
        }
        
        return notesArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PNotesCell.identifier) as! PNotesCell
        
        var notesObje = notesArr[indexPath.row]
        
        if searchActive {
            notesObje = filteredArray[indexPath.row]
        }
        
        cell.setPostdata(notesObje: notesObje)
        cell.myDelegate = self
        
        return cell
    }
    
    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: UISearchBarDelegate functions
    
    func searchBarTextDidEndEditing(_: UISearchBar) {
        //        searchActive = false;
        //        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //        searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            searchBar.resignFirstResponder()
            searchActive = false
            filteredArray.removeAll()
            tableview.reloadData()
        } else {
            searchActive = true
            filteredArray = notesArr.filter { ($0.notes)?.range(of: searchText, options: [.diacriticInsensitive, .caseInsensitive]) != nil
            }
            
            tableview.reloadData()
        }
    }
}

extension PNotesViewController: CLLocationManagerDelegate {
    func locationFetching() {
        // 1
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        // 1
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return
            
        // 2
        case .denied, .restricted:
            let alert = UIAlertController(title: "Location Services disabled", message: "Please enable Location Services in Settings", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
            return
        case .authorizedAlways, .authorizedWhenInUse:
            break
        @unknown default:
            break
        }
        
        // 4
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //        if let currentLocation = locations.last {
        ////            print("Current location: \(currentLocation)")
        //        }
    }
    
    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        //        print(error)
    }
}


extension PNotesViewController:NotesDelegate{
    func openProfile(postOBJ: PNotesModel) {
        if postOBJ.allowOther == 1 {
            if Helper.sharedHelper.validateEmailWithString((postOBJ.userKey ?? "") as NSString) {
                Helper.sharedHelper.showGlobalHUD(title: "", view: view)
                PWebService.sharedWebService.getUserDetail(key: postOBJ.userKey?.stringKey() ?? "") { _, user, _ in
                    DispatchQueue.main.async {
                        Helper.sharedHelper.dismissHUD(view: self.view)
                        self.renderDataFor(user: user as? PepsUser, viewType: .other)
                    }
                }
            }
        }
    }
    
    func renderDataFor(user: PepsUser?, viewType: MyProfileType) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let profile = storyboard.instantiateViewController(withIdentifier: PMyProfileListViewController.identifier) as! PMyProfileListViewController
        profile.screenType = .other
        profile.selectedUser = user
        navigationController?.pushViewController(profile, animated: true)
    }
    
    func moreAction(notesDetails: PNotesModel, moreBtn: UIButton) {
           let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
           
           // create an action
           let firstAction: UIAlertAction = UIAlertAction(title: "Edit", style: .default) { _ -> Void in
               self.btnEditClick(postDetails: notesDetails)
           }
           
           let secondAction: UIAlertAction = UIAlertAction(title: "Delete", style: .default) { _ -> Void in
               self.btnDeleteClick(postDetails: notesDetails)
           }
           
           let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { _ -> Void in }
           
           // add actions
           actionSheetController.addAction(firstAction)
           actionSheetController.addAction(secondAction)
           actionSheetController.addAction(cancelAction)
           
           if let presenter = actionSheetController.popoverPresentationController {
               presenter.sourceView = moreBtn
               presenter.sourceRect = moreBtn.bounds
           }
           
           // present an actionSheet...
           present(actionSheetController, animated: true, completion: nil)
       }
       
       func sendToCommentView(postOBJ: PNotesModel) {
           if postOBJ.userKey == PWebService.sharedWebService.currentUser?.email{
               let mainStoryboard = UIStoryboard(name: "Shared", bundle: nil)
               let vc = mainStoryboard.instantiateViewController(withIdentifier: PNotesUserListViewController.identifier) as? PNotesUserListViewController
               vc?.notes_row_key = postOBJ.row_key ?? ""
            vc?.notes = postOBJ
               navigationController?.pushViewController(vc!, animated: true)
           }
           else{
               let mainStoryboard = UIStoryboard(name: "Shared", bundle: nil)
               let vc = mainStoryboard.instantiateViewController(withIdentifier: PNotesCommentsViewController.identifier) as? PNotesCommentsViewController
               vc?.notes_row_key = postOBJ.row_key ?? ""
               navigationController?.pushViewController(vc!, animated: true)
           }
           
       }
    
    func imageDetailAction(postDetail _: PNotesModel, customView: PNotesCell) {
        let configuration = ImageViewerConfiguration { config in
            config.imageView = customView.userImageView
        }
        present(ImageViewerController(configuration: configuration), animated: true)
    }
}
