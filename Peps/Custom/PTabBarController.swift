//
//  PTabBarController.swift
//  Peps
//
//  Created by KP Tech on 20/04/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import UIKit

class PTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let mainStoryboard = UIStoryboard(name: "Shared", bundle: nil)

        let homeVC = mainStoryboard.instantiateViewController(withIdentifier: PPostsViewController.identifier) as! PPostsViewController
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "home_inactive_icon"), tag: 0)
        homeVC.screenType = .home

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myPostVC = storyboard.instantiateViewController(withIdentifier: PMyProfileListViewController.identifier) as! PMyProfileListViewController
        myPostVC.screenType = .own
        myPostVC.tabBarItem = UITabBarItem(title: "My Profile", image: UIImage(named: "user_icon"), tag: 3)

        let notesVC = mainStoryboard.instantiateViewController(withIdentifier: PNotesViewController.identifier)
        notesVC.tabBarItem = UITabBarItem(title: "C2G", image: UIImage(named: "group"), tag: 4)

        let moreVC = mainStoryboard.instantiateViewController(withIdentifier: PMoreViewController.identifier)
        moreVC.tabBarItem = UITabBarItem(title: "More", image: UIImage(named: "more_inactive_icon"), tag: 2)

        if !(PWebService.sharedWebService.currentUser?.is_worldwide_available ?? false) {
            let authenticateVC = mainStoryboard.instantiateViewController(withIdentifier: PAuthenticateViewController.identifier)
            authenticateVC.tabBarItem = UITabBarItem(title: "Worldwide", image: UIImage(named: "active_worldwide"), tag: 1)
            viewControllers = [homeVC, authenticateVC, myPostVC, notesVC, moreVC]
        } else {
            let worldwideVC = mainStoryboard.instantiateViewController(withIdentifier: PPostsViewController.identifier) as! PPostsViewController
            worldwideVC.tabBarItem = UITabBarItem(title: "Worldwide", image: UIImage(named: "active_worldwide"), tag: 1)
            worldwideVC.screenType = .worldwide
            viewControllers = [homeVC, worldwideVC, myPostVC, notesVC, moreVC]
        }
    }

    override func tabBar(_: UITabBar, didSelect _: UITabBarItem) {}
}
