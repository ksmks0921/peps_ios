//
//  PNotesFilterViewController.swift
//  Peps
//
//  Created by Shubham Garg on 05/11/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import UIKit

class PNotesFilterViewController: UIViewController {
    @IBOutlet weak var filterTableView: UITableView!
    var genderArr = ["Male", "Female", "Agender", "Androgyne", "Androgynous", "Bigender", "Cis", "Cisgender", "Cis Female", "Cis Male", "Cis Man", "Cis Woman", "Cisgender Female", "Cisgender Male", "Cisgender Man", "Cisgender Woman", "Female to Male", "FTM", "Gender Fluid", "Gender Nonconforming", "Gender Questioning", "Gender Variant", "Genderqueer", "Intersex"]
    var interestArr = ["Friend", "Date", "Chat", "Casual"]
    var delegate:PNotesViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterTableView.delegate = self
        filterTableView.dataSource = self
        filterTableView.tableFooterView = UIView(frame: .zero)
        self.title = "Filter"
        
        let filterDoneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.DoneBtnAxn))
        self.navigationItem.setRightBarButton(filterDoneButton, animated: false)
    }
    
    
    @objc func DoneBtnAxn(){
       self.navigationController?.popViewController(animated: true)
    }
    
    
    
}


extension PNotesFilterViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Gender"
        }
        return "Interest"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return genderArr.count
        }
        return interestArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if indexPath.section == 0 {
            cell.textLabel?.text = genderArr[indexPath.row]
            if (delegate?.selectedGenderArr.contains(genderArr[indexPath.row]) ?? false){
                cell.accessoryType = .checkmark
            }
            else{
               cell.accessoryType = .none
            }
        }
        else{
            cell.textLabel?.text = interestArr[indexPath.row]
            if (delegate?.selectedinterestArr.contains(interestArr[indexPath.row]) ?? false){
                cell.accessoryType = .checkmark
            }
            else{
               cell.accessoryType = .none
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if !(delegate?.selectedGenderArr.contains(genderArr[indexPath.row]) ?? false){
                delegate?.selectedGenderArr.append(genderArr[indexPath.row])
            }
            else{
                delegate?.selectedGenderArr.removeAll { (string) -> Bool in
                    return string == genderArr[indexPath.row]
                }
            }
        }
        else{
            if !(delegate?.selectedinterestArr.contains(interestArr[indexPath.row]) ?? false){
                delegate?.selectedinterestArr.append(interestArr[indexPath.row])
            }
            else{
                delegate?.selectedinterestArr.removeAll { (string) -> Bool in
                    return string == interestArr[indexPath.row]
                }
            }
        }
        if let cells = self.filterTableView.indexPathsForVisibleRows{
            self.filterTableView.reloadRows(at: cells, with: .automatic)
        }
    }
    
    
}
