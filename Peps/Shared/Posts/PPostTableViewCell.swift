//
//  PPostTableViewCell.swift
//  Peps
//
//  Created by Shubham Garg on 29/06/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import UIKit

protocol FeedDelegate {
    func sendToCommentView(postOBJ: PHomePosts)
    func like(postDetails: PHomePosts)
    func moreAction(postDetails: PHomePosts, moreBtn: UIButton)
    func playVideo(postDetails: PHomePosts)
    func imageDetailAction(postDetail: PHomePosts, customView: PPostTableViewCell)
    func openProfile(postOBJ: PHomePosts)
    func otherUserPostCreatedAction(homePost: PHomePosts, moreButton: UIButton)
}

class PPostTableViewCell: UITableViewCell {
    @IBOutlet var commentLbl: UILabel!
    @IBOutlet var likeLbl: UILabel!
    @IBOutlet var likeBtn: UIButton!
    @IBOutlet var commentBtn: UIButton!
    @IBOutlet var editBtn: UIButton!
    @IBOutlet var likeView: UIView!
    @IBOutlet var commentView: UIView!
    @IBOutlet var userImageView: UIImageView!
    var myDelegate: FeedDelegate?
    @IBOutlet var urlField: UILabel!
    @IBOutlet var postImage: UIImageView!
    @IBOutlet var postDisc: UILabel!
    @IBOutlet var postCreateddate: UILabel!
    @IBOutlet var userName: UILabel!
    var postOBJ: PHomePosts?
    @IBOutlet var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet var playVideoBtn: UIButton!
    @IBOutlet var adultLbl: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func imageTapped(tapGestureRecognizer _: UITapGestureRecognizer) {
        myDelegate?.imageDetailAction(postDetail: postOBJ!, customView: self)
    }

    func setPostdata(postObje: PHomePosts) {
        likeView.layer.cornerRadius = likeView.frame.height / 2
        commentView.layer.cornerRadius = commentView.frame.height / 2
        postOBJ = postObje
        if postObje.user_image_url != nil {
            userImageView.sd_setImage(with: URL(string: postObje.user_image_url!), placeholderImage: UIImage(named: "user"))
        } else {
            userImageView.image = UIImage(named: "user")
        }
//        if postObje.email == PWebService.sharedWebService.currentUser?.email || isAdminApp {
//            editBtn.isHidden = false
//        } else {
//            editBtn.isHidden = true
//        }
        if let comments = postOBJ?.comments {
            commentLbl.text = "\(comments.count)"
        } else {
            commentLbl.text = "0"
        }
        if let likes = postOBJ?.likes {
            likeLbl.text = "\(likes.count)"
        } else {
            likeLbl.text = "0"
        }
        if postObje.is_adult_content ?? false {
            adultLbl.isHidden = false
        }
        else{
            adultLbl.isHidden = true
        }
        userName.text = postObje.user_full_name
        postDisc.text = postObje.description
        postCreateddate.text = Helper.sharedHelper.getCreateddate(createddate: postObje.created_at ?? 0)

        if let url = postObje.url, url.trimmingCharacters(in: .whitespaces) != "" {
            urlField.isHidden = false
            let attributedString = NSMutableAttributedString(string: url)
            attributedString.addAttribute(.link, value: URL(string: url)!, range: NSRange(location: 0, length: url.count))
            urlField.attributedText = attributedString
        } else {
            urlField.isHidden = true
        }

        imageHeightConstraint.constant = 0
        postImage.contentMode = .scaleAspectFill
        postImage.image = UIImage(named: "image_placeholder")
        if let content_type = postObje.source_type, content_type == "video" {
            playVideoBtn.isHidden = false
            if let path = postObje.thumb_path, let url = URL(string: path) {
                postImage.sd_setImage(with: url, placeholderImage: UIImage(named: "image_placeholder"))
            }
            if UIDevice.current.userInterfaceIdiom == .pad {
                imageHeightConstraint.constant = 400
            } else {
                imageHeightConstraint.constant = 200
            }
        } else if let content_type = postObje.source_type, content_type == "audio" {
            postImage.image = UIImage(named: "audio_placeholder")
            playVideoBtn.setImage(nil, for: .normal)
            playVideoBtn.isHidden = false
            postImage.contentMode = .scaleAspectFit
            if UIDevice.current.userInterfaceIdiom == .pad {
                imageHeightConstraint.constant = 400
            } else {
                imageHeightConstraint.constant = 200
            }
        } else if let content_type = postObje.source_type, content_type == "image", let path = postObje.source_path, let url = URL(string: path) {
            playVideoBtn.isHidden = true
            postImage.sd_setImage(with: url, placeholderImage: UIImage(named: "image_placeholder"))
            if UIDevice.current.userInterfaceIdiom == .pad {
                imageHeightConstraint.constant = 400
            } else {
                imageHeightConstraint.constant = 200
            }
        } else {
            playVideoBtn.isHidden = true
            postImage.image = nil
            imageHeightConstraint.constant = 0
        }
    }

    @IBAction func likeBtnAxn(_: Any) {
        myDelegate?.like(postDetails: postOBJ!)
    }

    @IBAction func moreBtnAction(_ sender: UIButton) {
        if let postOBJ = postOBJ, let postEmail = postOBJ.email {
            if postEmail.stringKey() == PWebService.sharedWebService.userKey {
                myDelegate?.moreAction(postDetails: postOBJ, moreBtn: sender)
            } else {
                myDelegate?.otherUserPostCreatedAction(homePost: postOBJ, moreButton: sender)
            }
        }
    }

    @IBAction func playVideo(_: Any) {
        myDelegate?.playVideo(postDetails: postOBJ!)
    }

    @IBAction func sendToPostCommentView(_: UIButton) {
        myDelegate?.sendToCommentView(postOBJ: postOBJ!)
    }

    @IBAction func openProfile(_: Any) {
        myDelegate?.openProfile(postOBJ: postOBJ!)
    }
}

extension PPostTableViewCell: UITextViewDelegate {
    func textView(_: UITextView, shouldInteractWith URL: URL, in _: NSRange, interaction _: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}
