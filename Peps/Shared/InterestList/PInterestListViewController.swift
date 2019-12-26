//
//  PInterestListViewController.swift
//  Peps
//
//  Created by Shubham Garg on 29/05/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import Foundation
import UIKit

protocol IntersetsListDelegate {
    func selectedInterestArr(arr: [String])
}

class PInterestListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet var searchBar: UISearchBar!

    @IBOutlet var tableview: UITableView!
    var usersListArr = ["Politics", "News", "International/world news", "Comedy", "Hip-Hop", "Country", "Urban", "Cooking", "Fashion", "Healthy Lving", "Recreation", "Realty", "Science", "Business", "Sports", "History", "Career", "Travel", "Education"]
    var searchActive: Bool = false
    var filteredArray = [String]()
    var selectedInterests = [String]()
    var myDelegate: IntersetsListDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableview.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Interests"
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if searchActive {
            return filteredArray.count
        }

        return usersListArr.count
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        var usersObj = usersListArr[indexPath.row]

        if searchActive {
            usersObj = filteredArray[indexPath.row]
        }

        cell.textLabel?.text = usersObj

        if selectedInterests.contains(usersObj) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        var usersObj = usersListArr[indexPath.row]

        if searchActive == true {
            usersObj = filteredArray[indexPath.section]
        }

        if selectedInterests.contains(usersObj) {
            selectedInterests = selectedInterests.filter { (interest) -> Bool in
                if interest == usersObj {
                    return false
                }
                return true
            }
        } else {
            selectedInterests.append(usersObj)
        }

        tableView.reloadData()
    }

    @IBAction func doneBtnAction(_: UIButton) {
        if selectedInterests.count > 0 {
            myDelegate?.selectedInterestArr(arr: selectedInterests)
        }
        navigationController?.popViewController(animated: true)
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
            filteredArray = usersListArr.filter { ($0).range(of: searchText, options: [.diacriticInsensitive, .caseInsensitive]) != nil
            }

            tableview.reloadData()
        }
    }
}
