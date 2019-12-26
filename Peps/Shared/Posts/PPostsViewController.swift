//
//  HomeViewController.swift
//  Peps
//
//  Created by Shubham Garg on 14/05/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import AVKit
import SimpleImageViewer
import UIKit

public enum HomeScreenType {
    case none
    case home
    case worldwide
    case myProfileHome
    case myProfileWorldwide
    case myProfilePodcast
    case myProfileNewsSite
    case myProfileContentAccount
    case notes
}

enum MyProfileType {
    case none
    case own
    case other
}

class PPostsViewController: UIViewController {
    @IBOutlet var userName: UILabel!
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var newPostStack: UIStackView!
    @IBOutlet var userDetailStack: UIStackView!
    @IBOutlet var topHeaderView: UIView!
    @IBOutlet var feedTableView: UITableView!
    @IBOutlet var userId: UILabel!
    @IBOutlet var userAge: UILabel!
    @IBOutlet var createPostBtn: UIButton!
    @IBOutlet var profileBtn: UIButton!
    var refreshControl: UIRefreshControl!
    var postArr = [PHomePosts]()
    var copyArr = [PHomePosts]()
    var screenType = HomeScreenType.none
    var viewType = MyProfileType.own
    var selectedUser = PWebService.sharedWebService.currentUser
    var isAdultContentForWorldwide = true
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Refresh the data")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        feedTableView.addSubview(refreshControl)
        if isAdminApp {
            newPostStack.isHidden = true
            userDetailStack.isHidden = true
        } else {
            if viewType == .own {
                userDetailStack.isHidden = true
                newPostStack.isHidden = false
            } else {
                userDetailStack.isHidden = false
                newPostStack.isHidden = true
                userImage.sd_setImage(with: URL(string: selectedUser?.image_url ?? ""), placeholderImage: UIImage(named: "user"))
                userImage.layer.cornerRadius = userImage.frame.width / 2
                userName.text = selectedUser?.full_name
                userAge.text = selectedUser?.date_of_birth
                switch screenType {
                case .myProfilePodcast:
                    userId.text = selectedUser?.podcast_account_name
                case .myProfileContentAccount:
                    userId.text = selectedUser?.content_account_name
                case .myProfileNewsSite:
                    userId.text = selectedUser?.news_site_name
                case .myProfileWorldwide:
                    userId.text = selectedUser?.worldwide_user_id
                case .myProfileHome:
                    userId.text = selectedUser?.user_id
                default:
                    userId.text = selectedUser?.user_id
                }
            }
        }
        setupButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupButton()
        refresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        parent?.navigationItem.rightBarButtonItem = nil
    }

    func setupButton() {
        if screenType == .home {
            parent?.title = "Home"
            profileBtn.setTitle("Home Profile", for: .normal)
        } else if screenType == .worldwide {
            parent?.title = "Worldwide"
            profileBtn.setTitle("Worldwide Profile", for: .normal)
            let button = CenteredButton(type: .system)
            button.setImage(UIImage(named: "checkbox"), for: .normal)
            button.setTitle("Adult Content", for: .normal)
            button.addTarget(self, action: #selector(self.showhideAdultContent(sender:)), for: .touchUpInside)
//            button.sizeToFit()
            parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        } else {
            parent?.title = "My Profile"
            switch screenType {
            case .myProfilePodcast:
                profileBtn.setTitle("Podcast Profile", for: .normal)
            case .myProfileContentAccount:
                profileBtn.setTitle("Content Account Profile", for: .normal)
            case .myProfileNewsSite:
                profileBtn.setTitle("News Site Profile", for: .normal)
            case .myProfileWorldwide:
                title = "Worldwide Profile"
                profileBtn.setTitle("Worldwide Profile", for: .normal)
            case .myProfileHome:
                title = "Home Profile"
                profileBtn.setTitle("Home Profile", for: .normal)
            case .notes:
                profileBtn.setTitle("C2G Profile", for: .normal)
            default:
                profileBtn.setTitle("Home Profile", for: .normal)
            }
        }
    }
    
    @objc func showhideAdultContent(sender:UIButton){
        if isAdultContentForWorldwide{
            sender.setImage(UIImage(named: "uncheckbox"), for: .normal)
            isAdultContentForWorldwide = false
            copyArr = postArr
            postArr = postArr.filter({ (obj) -> Bool in
                return !(obj.is_adult_content ?? false)
            })
            self.feedTableView.reloadData()
        }
        else{
            sender.setImage(UIImage(named: "checkbox"), for: .normal)
            isAdultContentForWorldwide = true
            postArr = copyArr
            self.feedTableView.reloadData()
        }
    }

    @objc func refresh() {
        getPostList()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func createPostAction(_: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: PCreatePostViewController.identifier) as! PCreatePostViewController
        switch screenType {
        case .home, .myProfileHome:
            vc.postType = .homeFeed
        case .worldwide, .myProfileWorldwide:
            vc.postType = .worldwideFeed
        case .myProfileContentAccount:
            vc.postType = .contentFeed
        case .myProfileNewsSite:
            vc.postType = .newsSiteFeed
        case .myProfilePodcast:
            vc.postType = .podcastFeed
        default:
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func myProfileAction(_: UIButton) {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: PRegistrationViewController.identifier) as! PRegistrationViewController
        vc.screenType = screenType
        vc.user = selectedUser
        vc.editProfile = 1
        navigationController?.pushViewController(vc, animated: true)
    }

    func btnDeleteClick(postDetails: PHomePosts) {
        let alertController = UIAlertController(title: "Alert", message: "Are you sure, you want to delete this post?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { (_: UIAlertAction!) in
            Helper.sharedHelper.showGlobalHUD(title: "Deleting post..", view: self.view)
            PWebService.sharedWebService.removePost(rowKey: postDetails.row_Key!, childName: kPOSTS_LIST_T, completion: { status, _, message in

                Helper.sharedHelper.dismissHUD(view: self.view)
                if status == 100 {
                    Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
                    self.getPostList()
                }
            })
        }))
        alertController.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    func btnEditClick(postDetails: PHomePosts) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: PCreatePostViewController.identifier) as! PCreatePostViewController
        vc.postObj = postDetails
        switch screenType {
        case .home, .myProfileHome:
            vc.postType = .homeFeed
        case .worldwide, .myProfileWorldwide:
            vc.postType = .worldwideFeed
        case .myProfileContentAccount:
            vc.postType = .contentFeed
        case .myProfileNewsSite:
            vc.postType = .newsSiteFeed
        case .myProfilePodcast:
            vc.postType = .podcastFeed
        default:
            return
        }
        vc.editPost = 1
        navigationController?.pushViewController(vc, animated: true)
    }

    func getMyPostList() {
        Helper.sharedHelper.showGlobalHUD(title: "", view: view)
        if Helper.sharedHelper.isNetworkAvailable() {
            PWebService.sharedWebService.fetchRecord(childName: kPOSTS_LIST_T, queryChildName: "email", queryValue: (selectedUser?.email ?? "") as AnyObject, completion: { _, response, message in
                self.postArr.removeAll()
                Helper.sharedHelper.dismissHUD(view: self.view)
                if response != nil {
                    let arr = PHomePosts.modelsFromDictionaryArray(array: response as! NSArray)
                    if arr.count > 0 {
                        for post in arr {
                            if post.post_type == "homeFeed" && self.screenType == .myProfileHome {
                                self.postArr.append(post)
                            } else if post.post_type == "worldwideFeed" && self.screenType == .myProfileWorldwide {
                                self.postArr.append(post)
                            } else if post.post_type == "newsSiteFeed" && self.screenType == .myProfileNewsSite {
                                self.postArr.append(post)
                            } else if post.post_type == "contentFeed" && self.screenType == .myProfileContentAccount {
                                self.postArr.append(post)
                            } else if post.post_type == "podcastFeed" && self.screenType == .myProfilePodcast {
                                self.postArr.append(post)
                            }
                        }
                        self.feedTableView.reloadData()
                    } else {
                        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.feedTableView.frame.width, height: self.feedTableView.frame.height))
                        label.text = "There is no record available,Please post."
                        label.textAlignment = .center
                        self.feedTableView.backgroundView = label
                    }
                } else {
                    Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
                }
            })
        } else {
            DispatchQueue.main.async {
                Helper.sharedHelper.ShowAlert(str: "No Internet Connection", viewcontroller: self)
                Helper.sharedHelper.dismissHUD(view: self.view)
            }
        }
    }

    func getFeedPost() {
        Helper.sharedHelper.showGlobalHUD(title: "", view: view)
        if Helper.sharedHelper.isNetworkAvailable() {
            PWebService.sharedWebService.fetchRecord(childName: kPOSTS_LIST_T,
                                                     queryChildName: nil,
                                                     queryValue: nil,
                                                     completion: { status, response, message in
                                                         Helper.sharedHelper.dismissHUD(view: self.view)
                                                         self.parsed(status: status, response: response, message: message)
            })
        } else {
            DispatchQueue.main.async {
                Helper.sharedHelper.ShowAlert(str: "No Internet Connection", viewcontroller: self)
                Helper.sharedHelper.dismissHUD(view: self.view)
            }
        }
    }

    func parsed(status _: Int, response: AnyObject?, message: String?) {
        if response != nil {
            refreshControl.endRefreshing()
            let arr = PHomePosts.modelsFromDictionaryArray(array: response as! NSArray)
            postArr.removeAll()
            if arr.count > 0 {
                for post in arr {
                    if isAdminApp {
                        if screenType == .home && (post.post_type == "homeFeed" || post.post_type == "newsSiteFeed" || post.post_type == "contentFeed") && !(post.is_adult_content ?? false) {
                            postArr.append(post)
                        } else if screenType == .worldwide && (post.post_type == "worldwideFeed" || post.post_type == "newsSiteFeed" || post.post_type == "contentFeed" || post.post_type == "podcastFeed") {
                            postArr.append(post)
                        }
                    } else if let interests = selectedUser?.interests,
                        let post_interests = post.interests,
                        post_interests.contains(where: { (element) -> Bool in
                            if self.screenType == .home && interests.contains(element) && (post.post_type == "homeFeed" || post.post_type == "newsSiteFeed" || post.post_type == "contentFeed") && !(post.is_adult_content ?? false) {
                                return true
                            } else if self.screenType == .worldwide && interests.contains(element) && (post.post_type == "worldwideFeed" || post.post_type == "newsSiteFeed" || post.post_type == "contentFeed" || post.post_type == "podcastFeed") {
                                return true
                            } else {
                                return false
                            }
                        }) {
                        
                        if let postEmail = post.email, PWebService.sharedWebService.myBlockedUsers.contains(postEmail.stringKey()) {
                            
                        } else {
                            postArr.append(post)
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.feedTableView.reloadData()
                }
            } else {
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: feedTableView.frame.width, height: feedTableView.frame.height))
                label.text = "There is no record available, please post."
                label.textAlignment = .center
                feedTableView.backgroundView = label
            }
        } else {
            Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
        }
    }

    func getPostList() {
        if screenType == .home || screenType == .worldwide {
            getFeedPost()
        } else {
            getMyPostList()
        }
    }
}

extension PPostsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return postArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPostTableViewCell.identifier) as! PPostTableViewCell
        cell.setPostdata(postObje: postArr[indexPath.row])
        cell.myDelegate = self

        return cell
    }

    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {}

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 0
    }

    func tableView(_: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        return UIView(frame: .zero)
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension PPostsViewController: FeedDelegate {
    func openProfile(postOBJ: PHomePosts) {
        if screenType == .home || screenType == .worldwide {
            if Helper.sharedHelper.validateEmailWithString((postOBJ.email ?? "") as NSString) {
                Helper.sharedHelper.showGlobalHUD(title: "", view: view)
                PWebService.sharedWebService.getUserDetail(key: postOBJ.email?.stringKey() ?? "") { _, user, _ in
                    DispatchQueue.main.async {
                        Helper.sharedHelper.dismissHUD(view: self.view)
                        self.renderDataFor(user: user as? PepsUser, viewType: .other)
                    }
                }
            }
        }
    }

    func renderDataFor(user: PepsUser?, viewType: MyProfileType) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Shared", bundle: nil)
        let profile = storyboard.instantiateViewController(withIdentifier: PPostsViewController.identifier) as! PPostsViewController
        var currentScreenType = screenType
        if currentScreenType == .home {
            currentScreenType = .myProfileHome
        } else if currentScreenType == .worldwide {
            currentScreenType = .myProfileWorldwide
        }
        profile.screenType = currentScreenType
        profile.selectedUser = user
        profile.viewType = viewType
        navigationController?.pushViewController(profile, animated: true)
    }

    func like(postDetails: PHomePosts) {
        Helper.sharedHelper.showGlobalHUD(title: "Posting...", view: view)

        let commentsdict = NSMutableDictionary()
        commentsdict.setValue(selectedUser?.full_name, forKey: "user_name")
        commentsdict.setValue(selectedUser?.email, forKey: kEmail)
        commentsdict.setValue(selectedUser?.email, forKey: kUser_Id)
        commentsdict.setValue(selectedUser?.image_url, forKey: "profile_url")

        PWebService.sharedWebService.addlike(parameters: commentsdict as! [String: AnyObject],
                                             rowKey: postDetails.row_Key!,
                                             childName: kPOSTS_LIST_T,
                                             receiverEmail: postDetails.email!.stringKey()) { status, _, message in

            Helper.sharedHelper.dismissHUD(view: self.view)

            if status == 100 {
                self.getPostList()
            } else {
                Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
            }
        }
    }

    func playVideo(postDetails: PHomePosts) {
        if let url = URL(string: postDetails.source_path ?? "") {
            let player = AVPlayer(url: url)
            let vc = AVPlayerViewController()
            vc.player = player

            present(vc, animated: true) {
                vc.player?.play()
            }
        }
    }

    func imageDetailAction(postDetail _: PHomePosts, customView: PPostTableViewCell) {
        let configuration = ImageViewerConfiguration { config in
            config.imageView = customView.postImage
        }
        present(ImageViewerController(configuration: configuration), animated: true)
    }

    func moreAction(postDetails: PHomePosts, moreBtn: UIButton) {
        if selectedUser?.email == postDetails.email || isAdminApp {
            let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

            // create an action
            let firstAction: UIAlertAction = UIAlertAction(title: "Edit", style: .default) { _ -> Void in
                self.btnEditClick(postDetails: postDetails)
            }

            let secondAction: UIAlertAction = UIAlertAction(title: "Delete", style: .default) { _ -> Void in
                self.btnDeleteClick(postDetails: postDetails)
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
    }

    func sendToCommentView(postOBJ: PHomePosts) {
        let vc = storyboard?.instantiateViewController(withIdentifier: PCommentViewController.identifier) as! PCommentViewController
        vc.postOBJ = postOBJ
        vc.postType = screenType
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func otherUserPostCreatedAction(homePost: PHomePosts, moreButton: UIButton) {
        // create an actionSheet
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // create an action
        let firstAction: UIAlertAction = UIAlertAction(title: "Report User", style: .default) { _ -> Void in

            Helper.sharedHelper.showGlobalHUD(title: "", view: self.view)

            var parameters = [String: AnyObject]()
            parameters["email"] = homePost.email as AnyObject
            parameters["row_key"] = homePost.row_Key as AnyObject
            parameters["type"] = kPOSTS_LIST_T as AnyObject

            PWebService.sharedWebService.reportUser(parameters: parameters, completion: { _, _, message in
                Helper.sharedHelper.dismissHUD(view: self.view)
                Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
            })
        }

        let secondAction: UIAlertAction = UIAlertAction(title: "Block User", style: .default) { _ -> Void in

            Helper.sharedHelper.showGlobalHUD(title: "", view: self.view)

            var parameters = [String: AnyObject]()
            parameters["email"] = homePost.email as AnyObject
            parameters["row_key"] = homePost.row_Key as AnyObject
            parameters["type"] = kPOSTS_LIST_T as AnyObject

            PWebService.sharedWebService.blockUser(parameters: parameters, completion: { _, _, message in
                Helper.sharedHelper.dismissHUD(view: self.view)
                Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
                
                if let postEmail = homePost.email?.stringKey() {
                    PWebService.sharedWebService.myBlockedUsers.append(postEmail)
                }
                self.getPostList()
            })
        }

        let offensiveAction: UIAlertAction = UIAlertAction(title: "Offensive or inappropriate content.", style: .default) { _ -> Void in

            Helper.sharedHelper.showGlobalHUD(title: "", view: self.view)

            var parameters = [String: AnyObject]()
            parameters["email"] = homePost.email as AnyObject
            parameters["row_key"] = homePost.row_Key as AnyObject
            parameters["type"] = kPOSTS_LIST_T as AnyObject
            parameters["offensive_content"] = "1" as AnyObject

            PWebService.sharedWebService.offensiveContentAction(parameters: parameters, completion: { _, _, message in
                Helper.sharedHelper.dismissHUD(view: self.view)
                Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)

                self.getPostList()
            })
        }

        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { _ -> Void in }

        // add actions
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(offensiveAction)
        actionSheetController.addAction(cancelAction)

        if let presenter = actionSheetController.popoverPresentationController {
            presenter.sourceView = moreButton
            presenter.sourceRect = moreButton.bounds
        }

        // present an actionSheet...
        present(actionSheetController, animated: true, completion: nil)
    }

}


