//
//  PPostHeaderView.swift
//  Peps
//
//  Created by Shubham Garg on 14/05/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import UIKit

class PPostHeaderView: UITableViewHeaderFooterView {
    @IBOutlet var commentLbl: UILabel!
    @IBOutlet var likeLbl: UILabel!
    @IBOutlet var likeBtn: UIButton!
    @IBOutlet var editBtn: UIButton!
    @IBOutlet var likeView: UIView!
    @IBOutlet var commentView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var commentField: UITextField!
    var myDelegate: FeedDelegate?
    @IBOutlet var urlField: UILabel!
    @IBOutlet var postImage: UIImageView!
    @IBOutlet var postDisc: UILabel!
    @IBOutlet var postCreateddate: UILabel!
    @IBOutlet var userName: UILabel!
    var postOBJ: PHomePosts?
    @IBOutlet var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet var playVideoBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func imageTapped(tapGestureRecognizer _: UITapGestureRecognizer) {
//        myDelegate?.imageDetailAction(postDetail: postOBJ!, customView: self)
    }

    func setPostdata(postObje: PHomePosts) {
        likeView.layer.cornerRadius = likeView.frame.height / 2
        commentView.layer.cornerRadius = commentView.frame.height / 2
        postOBJ = postObje
        if postObje.user_image_url != nil {
            imageView.sd_setImage(with: URL(string: postObje.user_image_url!), placeholderImage: UIImage(named: "user"))
        } else {
            imageView.image = UIImage(named: "user")
        }
        if postObje.email == PWebService.sharedWebService.currentUser?.email || isAdminApp {
            editBtn.isHidden = false
        } else {
            editBtn.isHidden = true
        }
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

        if let content_type = postObje.source_type, content_type == "video" {
            playVideoBtn.isHidden = false
            postImage.image = UIImage(named: "image_placeholder")
            postImage.contentMode = .center
        } else if let content_type = postObje.source_type, content_type == "audio" {
            postImage.image = UIImage(named: "audio_placeholder")
            playVideoBtn.setImage(nil, for: .normal)
            playVideoBtn.isHidden = false
            postImage.contentMode = .scaleAspectFit
        } else if postObje.source_path != nil {
            //            self.playVideoBtn.isHidden = true
            postImage.sd_setImage(with: URL(string: postObje.source_path!), placeholderImage: UIImage(named: "image_placeholder"))
        } else {
            //            self.playVideoBtn.isHidden = true
            postImage.image = nil
        }
    }

    @IBAction func likeBtnAxn(_: Any) {
        myDelegate?.like(postDetails: postOBJ!)
    }

    @IBAction func moreBtnAction(_ sender: UIButton) {
        myDelegate?.moreAction(postDetails: postOBJ!, moreBtn: sender)
    }

    @IBAction func playVideo(_: Any) {
        myDelegate?.playVideo(postDetails: postOBJ!)
    }

    @IBAction func sendPostComment(_: UIButton) {
        endEditing(true)
        guard commentField.text != "" else {
            Helper.sharedHelper.showGlobalAlertwithMessage("Please enter the comments.")
            return
        }

//        myDelegate?.sendComment(commentString: commentField.text!, postDetails: postOBJ!)
        commentField.text = ""
    }
}

extension PPostHeaderView: UITextViewDelegate {
    func textView(_: UITextView, shouldInteractWith URL: URL, in _: NSRange, interaction _: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}
