//
//  PPostCommentViewCell.swift
//  Peps
//
//  Created by Shubham Garg on 14/05/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import UIKit

protocol PPostCommentViewCellDelegate {
    func deleteAction(comment: PComments, moreBtn: UIButton, indexPath: IndexPath)
    func otherUserPostCreatedAction(comment: PComments, moreButton: UIButton)
}

class PPostCommentViewCell: UITableViewCell {
    @IBOutlet var commentDescriptionLabel: UILabel!
    @IBOutlet var commentDateLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var commentUserNameLabel: UILabel!
    @IBOutlet var moreBtn: UIButton!
    var indexPath: IndexPath!
    var cellDelegate: PPostCommentViewCellDelegate?
    var comment: PComments?

    func setdata(detailDataObj: PComments, indexPath: IndexPath) {
        self.indexPath = indexPath
        comment = detailDataObj
        commentUserNameLabel.text = detailDataObj.user_name ?? ""
        commentDescriptionLabel.text = detailDataObj.comment_text ?? ""
        commentDateLabel.text = Helper.sharedHelper.getCreateddate(createddate: detailDataObj.created_at ?? 0)
        if let url = detailDataObj.profile_url {
            profileImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "user"))
        }
    }

    @IBAction func deleteAction(id _: Any) {
        if let c = self.comment {
            if PWebService.sharedWebService.currentUser?.email == comment?.email || isAdminApp {
                cellDelegate?.deleteAction(comment: c, moreBtn: moreBtn, indexPath: indexPath)
            } else {
                cellDelegate?.otherUserPostCreatedAction(comment: c, moreButton: moreBtn)
            }
        }
    }
}
