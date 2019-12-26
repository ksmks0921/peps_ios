//
//  PNotesCell.swift
//  Peps
//
//  Created by sivaprasad reddy on 02/07/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import UIKit
protocol NotesDelegate {
    func sendToCommentView(postOBJ: PNotesModel)
    func imageDetailAction(postDetail: PNotesModel, customView: PNotesCell)
    func moreAction(notesDetails: PNotesModel, moreBtn: UIButton)
    func openProfile(postOBJ: PNotesModel)
}

class PNotesCell: UITableViewCell {
    @IBOutlet var notesLabel: UILabel!
    @IBOutlet var genderLabel: UILabel!
    @IBOutlet var lookingforLabel: UILabel!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userImageView: UIImageView!
    var userNotesOBJ: PNotesModel?
    var myDelegate: NotesDelegate?
    @IBOutlet weak var openProfileBtn: UIButton!
    
    @IBOutlet var moreBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func imageTapped(tapGestureRecognizer _: UITapGestureRecognizer) {
        myDelegate?.imageDetailAction(postDetail: userNotesOBJ!, customView: self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setPostdata(notesObje: PNotesModel) {
        userNameLabel.text = notesObje.notesFrom
        userNotesOBJ = notesObje
        lookingforLabel.text = notesObje.lookingFor
        genderLabel.text = "\(notesObje.iAm ?? ""), \(notesObje.age ?? 0)"
        notesLabel.text = notesObje.notes
        if let urlStr = notesObje.imageUrl {
            userImageView.sd_setImage(with: URL(string: urlStr), placeholderImage: UIImage(named: "image_placeholder"))
        } else {
            userImageView.image = #imageLiteral(resourceName: "image_placeholder")
        }
        if notesObje.userKey == PWebService.sharedWebService.currentUser?.email {
            moreBtn.isHidden = false
        } else {
            moreBtn.isHidden = true
        }
    }
    
    @IBAction func sendToPostCommentView(_: UIButton) {
        myDelegate?.sendToCommentView(postOBJ: userNotesOBJ!)
    }
    
    @IBAction func editBtnAction(_ sender: UIButton) {
        myDelegate?.moreAction(notesDetails: userNotesOBJ!, moreBtn: sender)
    }
    
    @IBAction func openProfile(_ sender: Any) {
        if let obj = userNotesOBJ{
            myDelegate?.openProfile(postOBJ: obj)
        }
        
    }
    
}
