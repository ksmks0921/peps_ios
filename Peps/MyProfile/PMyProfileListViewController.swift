//
//  PMyProfileListViewController.swift
//  Peps
//
//  Created by KP Tech on 29/06/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import UIKit

class PMyProfileListViewController: UIViewController {
    open var option: TabPageOption = TabPageOption()
    var pageViewController = TabPageViewController()
    var tabView: TabView!
    var selectedUser: PepsUser?
    var screenType: MyProfileType = .none

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if screenType == .own {
            selectedUser = PWebService.sharedWebService.currentUser
            parent?.title = "My Profile"
        } else {
            title = selectedUser?.user_id ?? ""
        }
        renderDataFor(user: selectedUser)
    }

    func renderDataFor(user: PepsUser?) {
        option.tabBackgroundColor = MainCgColor
        option.currentColor = UIColor.white
        option.isTranslucent = false
        pageViewController.option = option

        pageViewController.option.tabWidth = UIScreen.main.bounds.size.width / CGFloat(pageViewController.tabItems.count)
        pageViewController.option.hidesTopViewOnSwipeType = .all

        let storyboard: UIStoryboard = UIStoryboard(name: "Shared", bundle: nil)
        let mainProfile = storyboard.instantiateViewController(withIdentifier: PPostsViewController.identifier) as! PPostsViewController
        mainProfile.screenType = .myProfileHome
        mainProfile.selectedUser = selectedUser
        mainProfile.viewType = screenType
        let worldwideProfile = storyboard.instantiateViewController(withIdentifier: PPostsViewController.identifier) as! PPostsViewController
        worldwideProfile.screenType = .myProfileWorldwide
        worldwideProfile.selectedUser = selectedUser
        worldwideProfile.viewType = screenType
        let myNotes = storyboard.instantiateViewController(withIdentifier: PNotesViewController.identifier) as! PNotesViewController
        myNotes.screenType = 1

        pageViewController.tabItems = [(mainProfile, "Home"), (worldwideProfile, "Worldwide")]
        if (user?.is_news_account_available ?? 0) == 2 {
            let newsAccountProfile = storyboard.instantiateViewController(withIdentifier: PPostsViewController.identifier) as! PPostsViewController
            newsAccountProfile.selectedUser = selectedUser
            newsAccountProfile.screenType = .myProfileNewsSite
            newsAccountProfile.viewType = screenType
            pageViewController.tabItems.append((newsAccountProfile, "News Site"))
        }

        if (user?.is_content_account_available ?? 0) == 2 {
            let contentProfile = storyboard.instantiateViewController(withIdentifier: PPostsViewController.identifier) as! PPostsViewController
            contentProfile.selectedUser = selectedUser
            contentProfile.screenType = .myProfileContentAccount
            contentProfile.viewType = screenType
            pageViewController.tabItems.append((contentProfile, "Content Account"))
        }

        if (user?.is_podcast_account_available ?? 0) == 2 {
            let podcastAccountProfile = storyboard.instantiateViewController(withIdentifier: PPostsViewController.identifier) as! PPostsViewController
            podcastAccountProfile.selectedUser = selectedUser
            podcastAccountProfile.screenType = .myProfilePodcast
            podcastAccountProfile.viewType = screenType
            pageViewController.tabItems.append((podcastAccountProfile, "Podcast"))
        }
        pageViewController.tabItems.append((myNotes, "Come2Gether"))
        addChild(pageViewController)
        var frame = pageViewController.view.frame
        frame.origin.y = 40
        pageViewController.view.frame = frame
        view.addSubview(pageViewController.view)
        tabView = configuredTabView()
    }

    fileprivate func configuredTabView() -> TabView {
        let tabView = TabView(isInfinity: false, option: option)
        tabView.translatesAutoresizingMaskIntoConstraints = false

        let height = NSLayoutConstraint(item: tabView,
                                        attribute: .height,
                                        relatedBy: .equal,
                                        toItem: nil,
                                        attribute: .height,
                                        multiplier: 1.0,
                                        constant: option.tabHeight)
        tabView.addConstraint(height)
        view.addSubview(tabView)

        let top = NSLayoutConstraint(item: tabView,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: topLayoutGuide,
                                     attribute: .bottom,
                                     multiplier: 1.0,
                                     constant: 0.0)

        let left = NSLayoutConstraint(item: tabView,
                                      attribute: .leading,
                                      relatedBy: .equal,
                                      toItem: view,
                                      attribute: .leading,
                                      multiplier: 1.0,
                                      constant: 0.0)

        let right = NSLayoutConstraint(item: view as Any,
                                       attribute: .trailing,
                                       relatedBy: .equal,
                                       toItem: tabView,
                                       attribute: .trailing,
                                       multiplier: 1.0,
                                       constant: 0.0)

        view.addConstraints([top, left, right])

        tabView.pageTabItems = pageViewController.tabItems.map({ $0.title })
        tabView.updateCurrentIndex(0, shouldScroll: true)

        tabView.pageItemPressedBlock = { [weak self] (index: Int, direction: UIPageViewController.NavigationDirection) in
            self?.pageViewController.displayControllerWithIndex(index, direction: direction, animated: true)
            if self?.screenType == .other {
                switch index {
                case 0:
                    self?.parent?.title = self?.selectedUser?.user_id
                case 1:
                    self?.parent?.title = self?.selectedUser?.worldwide_user_id
                case 2:
                    self?.parent?.title = self?.selectedUser?.news_site_name
                case 3:
                    self?.parent?.title = self?.selectedUser?.content_account_name
                case 4:
                    self?.parent?.title = self?.selectedUser?.podcast_account_name
                default:
                    self?.parent?.title = "My Profile"
                }
            }
        }

        return tabView
    }
}
