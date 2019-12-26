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
        let sharedStoryboard = UIStoryboard(name: "Shared", bundle: nil)
        let homeVC = sharedStoryboard.instantiateViewController(withIdentifier: PPostsViewController.identifier) as! PPostsViewController
        homeVC.screenType = .home
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "home_inactive_icon"), tag: 0)

        let worldwideVC = sharedStoryboard.instantiateViewController(withIdentifier: PPostsViewController.identifier) as! PPostsViewController
        worldwideVC.screenType = .worldwide
        worldwideVC.tabBarItem = UITabBarItem(title: "Worldwide", image: UIImage(named: "active_worldwide"), tag: 1)

        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let authenticateVC = mainStoryboard.instantiateViewController(withIdentifier: PAuthListViewController.identifier)
        authenticateVC.tabBarItem = UITabBarItem(title: "AuthList", image: UIImage(named: "active_worldwide"), tag: 2)

        let moreVC = sharedStoryboard.instantiateViewController(withIdentifier: PMoreViewController.identifier)
        moreVC.tabBarItem = UITabBarItem(title: "More", image: UIImage(named: "more_inactive_icon"), tag: 3)
        viewControllers = [homeVC, worldwideVC, authenticateVC, moreVC]
    }

    override func tabBar(_: UITabBar, didSelect _: UITabBarItem) {}
}
