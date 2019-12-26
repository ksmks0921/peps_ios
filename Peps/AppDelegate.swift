//
//  AppDelegate.swift
//  Peps
//
//  Created by KP Tech on 12/05/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import Firebase
import IQKeyboardManagerSwift
import UIKit

let googleApiKey = "AIzaSyDkJt1vmPeeu21nbXCoSdLT2ivi9acwN8U"
let isAdminApp = false
//let appColor = UIColor(red: 28.0 / 255.0, green: 96.0 / 255.0, blue: 159.0 / 255.0, alpha: 1.0)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var ref: DatabaseReference!
    var fbUser: UserInfo?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        ref = Database.database().reference()
        IQKeyboardManager.shared.enable = true
        let userDefaults = UserDefaults.standard
        let decoded = userDefaults.data(forKey: "CurrentUser")
        Helper.sharedHelper.setNavigationBar()
        if let currentUser = try? JSONDecoder().decode(PepsUser.self, from: decoded ?? Data()) {
            PWebService.sharedWebService.currentUser = currentUser
            PWebService.sharedWebService.autoLogin { _, _, _ in
                DispatchQueue.main.async {
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let tabBarController = sb.instantiateInitialViewController() as! UITabBarController
                    let navVC = UINavigationController(rootViewController: tabBarController)
                    navVC.navigationBar.barTintColor = MainCgColor
                    self.window?.rootViewController = navVC
                    self.window?.makeKeyAndVisible()
                }
            }
        } else {
            let sb = UIStoryboard(name: "Login", bundle: nil)
            let loginController = sb.instantiateViewController(withIdentifier: "PLoginViewController") as! PLoginViewController
            let navVC = UINavigationController(rootViewController: loginController)
            navVC.isNavigationBarHidden = true
            navVC.navigationBar.barTintColor = MainCgColor
            window?.rootViewController = navVC
            self.window?.makeKeyAndVisible()
        }
//        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        return true
    }

    func applicationWillResignActive(_: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
