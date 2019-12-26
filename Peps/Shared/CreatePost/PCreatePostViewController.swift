//
//  PCreatePostViewController.swift
//  Peps
//
//  Created by Shubham Garg on 15/05/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import GSMessages
import Photos
import UIKit
import ZFTokenField

enum UploadType: String {
    case video
    case image
    case audio
    case none

    mutating func uploadType(type: String) -> UploadType {
        switch type {
        case UploadType.video.rawValue:
            return .video
        case UploadType.image.rawValue:
            return .image
        case UploadType.audio.rawValue:
            return .audio
        case UploadType.none.rawValue:
            return .none
        default:
            return .image
        }
    }
}

enum PostType: String {
    case homeFeed
    case worldwideFeed
    case newsSiteFeed
    case contentFeed
    case podcastFeed
}

class PCreatePostViewController: UITableViewController, UINavigationControllerDelegate {
    @IBOutlet var adultContentLbl: UILabel!
    @IBOutlet var postImageView: UIImageView!
    @IBOutlet var adultContentBtn: UIButton!
    @IBOutlet var postDescField: UITextView!
    @IBOutlet var urlField: UITextView!
    @IBOutlet var imageSelectionBtn: UIButton!
    @IBOutlet var interestView: ZFTokenField!
    @IBOutlet var interestLbl: UILabel!
    @IBOutlet var submitView: UIView!

    var selectedInterestArr = [String]()
    var tokenHeight = CGFloat(20)
    var margin = CGFloat(4)
    var marginLbl = CGFloat(4)

    var mediaPicker = UIImagePickerController()
    var postObj: PHomePosts?
    var editPost = 0
    var uploadType: UploadType = .none
    var videoData: Data?
    var postType: PostType = .homeFeed
    var myPickerView: UIPickerView!
    var recordedAudioURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Post"

        if postType == .newsSiteFeed {
            title = "Create News Post"
        } else if postType == .contentFeed {
            title = "Create Content Post"
        } else if postType == .podcastFeed {
            title = "Create Podcast Post"
        } else if postType == .homeFeed {
            title = "Create Home Post"
        } else if postType == .worldwideFeed {
            title = "Create Worldwide Post"
        }

        if editPost == 1 {
            title = "Edit Post"
            postDescField.text = postObj?.description
            urlField.text = postObj?.url
            uploadType = uploadType.uploadType(type: postObj?.source_type ?? "image")
            if uploadType == .video {
                if let url = postObj?.thumb_path {
                    postImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "image_placeholder"))
                    postImageView.contentMode = .scaleAspectFit
                }
            } else {
                if let url = postObj?.source_path {
                    postImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "image_placeholder"))
                    postImageView.contentMode = .scaleAspectFit
                }
            }
        }

        tableView.tableFooterView = submitView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        interestView.layer.cornerRadius = 0
        mediaPicker.delegate = self
        Helper.sharedHelper.setDottedBorder(view: postImageView)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func interestAction(_: Any) {
        let storyboard = UIStoryboard(name: "Shared", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: PInterestListViewController.identifier) as! PInterestListViewController
        vc.myDelegate = self
        vc.selectedInterests = selectedInterestArr
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func imageSelectfromCameraAction(_ sender: UIButton) {
        if postType == .homeFeed {
            openCamera()
        } else if postType == .podcastFeed {
            let alert = UIAlertController(title: "Select Image/Video", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Video", style: .default, handler: { _ in
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                    self.mediaPicker.sourceType = UIImagePickerController.SourceType.camera
                    self.mediaPicker.mediaTypes = ["public.movie"]
                    self.present(self.mediaPicker, animated: true, completion: nil)
                } else {
                    Helper.sharedHelper.showGlobalAlertwithMessage("Camera is not exist.", vc: self)
                }
            }))
            alert.addAction(UIAlertAction(title: "Audio", style: .default, handler: { _ in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: AudioRecorderAndPlayerViewController.identifier) as! AudioRecorderAndPlayerViewController
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }))

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceRect = sender.bounds
                popoverController.sourceView = sender
            }
            present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Select Image/Video", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.openCamera()
            }))

            alert.addAction(UIAlertAction(title: "Gallary", style: .default, handler: { _ in
                self.mediaPicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                self.mediaPicker.mediaTypes = ["public.movie", "public.image"]
                self.present(self.mediaPicker, animated: true, completion: nil)
            }))

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceRect = sender.bounds
                popoverController.sourceView = sender
            }
            present(alert, animated: true, completion: nil)
        }
    }

    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            mediaPicker.sourceType = UIImagePickerController.SourceType.camera
            mediaPicker.mediaTypes = ["public.movie", "public.image"]
            present(mediaPicker, animated: true, completion: nil)
        } else {
            Helper.sharedHelper.showGlobalAlertwithMessage("Camera is not exist.", vc: self)
        }
    }

    func imageSelecetfromGalleryAction(_: UIButton) {
        mediaPicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        present(mediaPicker, animated: true, completion: nil)
    }

    @IBAction func publishBtnAction(_: UIButton) {
        let folderNamePath = kPOSTS_LIST_T

        // Check for data validation
        // check if image or text are there

        var mediaFileOrText = false
        if let postImage = postImageView.image, postImage != UIImage(named: "select_img") {
            mediaFileOrText = true
        } else if let _ = videoData {
            mediaFileOrText = true
        } else if postDescField.text != "say something" {
            mediaFileOrText = true
        }

        if mediaFileOrText {
            if uploadType == .image {
                uploadPostWithImage(folderNamePath: folderNamePath)
            } else if uploadType == .video {
                uploadPostWithVideo(folderNamePath: folderNamePath)

            } else if uploadType == .audio {
                uploadPostWithAudio(folderNamePath: folderNamePath)
            } else {
                if postType == .homeFeed {
                    showMessage("Please select image or image and text both.", type: .error)
                } else {
                    if postType == .worldwideFeed && selectedInterestArr.count < 1 {
                        showMessage("Please select interests.", type: .error)
                    } else {
                        uploadPost(imageString: nil, tumbString: nil)
                    }
                }
            }
        } else {
            if uploadType == .image {
                showMessage("Please select image or text.", type: .error)
            } else if uploadType == .video {
                showMessage("Please select video or text.", type: .error)
            } else if uploadType == .audio {
                showMessage("Please select audio or text.", type: .error)
            } else {
                showMessage("Please select anything.", type: .error)
            }
        }
    }

    @IBAction func adultContentStatus(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }

    func uploadPostWithImage(folderNamePath: String) {
        if let postImage = postImageView.image {
            Helper.sharedHelper.showGlobalHUD(title: "Posting...", view: view)
            PWebService.sharedWebService.uploadImage(image: postImage,
                                                     imageName: Helper.sharedHelper.generateName(),
                                                     folderNamePath: folderNamePath) { status, response, message in
                Helper.sharedHelper.dismissHUD(view: self.view)
                if status == 100 {
                    let str = NSString(format: "%@", response as! CVarArg)
                    self.uploadPost(imageString: str as String, tumbString: nil)
                } else {
                    Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
                }
            }
        } else {
            uploadPost(imageString: nil, tumbString: nil)
        }
    }

    func uploadPostWithVideo(folderNamePath: String) {
        if let videoData = videoData {
            Helper.sharedHelper.showGlobalHUD(title: "Posting...", view: view)
            PWebService.sharedWebService.uploadVideo(data: videoData,
                                                     videoName: Helper.sharedHelper.generateName(),
                                                     folderNamePath: folderNamePath) { status, response, message in
                Helper.sharedHelper.dismissHUD(view: self.view)
                if status == 100 {
                    let str = NSString(format: "%@", response as! CVarArg)
                    if let postImage = self.postImageView.image {
                        Helper.sharedHelper.showGlobalHUD(title: "Posting...", view: self.view)
                        PWebService.sharedWebService.uploadImage(image: postImage,
                                                                 imageName: Helper.sharedHelper.generateName(),
                                                                 folderNamePath: folderNamePath) { status, response, message in
                            Helper.sharedHelper.dismissHUD(view: self.view)
                            if status == 100 {
                                let imageString = NSString(format: "%@", response as! CVarArg)
                                self.uploadPost(imageString: str as String, tumbString: imageString as String)
                            } else {
                                Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
                            }
                        }
                    }
                } else {
                    Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
                }
            }
        } else {
            uploadPost(imageString: nil, tumbString: nil)
        }
    }

    func uploadPostWithAudio(folderNamePath: String) {
        if let url = recordedAudioURL, let audioData: Data = try? Data(contentsOf: url) {
            Helper.sharedHelper.showGlobalHUD(title: "Posting...", view: view)
            PWebService.sharedWebService.uploadVideo(data: audioData,
                                                     videoName: Helper.sharedHelper.generateName(),
                                                     folderNamePath: folderNamePath) { status, response, message in
                Helper.sharedHelper.dismissHUD(view: self.view)
                if status == 100 {
                    let str = NSString(format: "%@", response as! CVarArg)
                    self.uploadPost(imageString: str as String, tumbString: nil)
                } else {
                    Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
                }
            }
        } else {
            Helper.sharedHelper.showGlobalHUD(title: "Please upload audio file.", view: view)
        }
    }

    func uploadPost(imageString: String?, tumbString: String?) {
        let feedDict = NSMutableDictionary()
        feedDict.setValue(postType.rawValue, forKey: "post_type")
        if let imageString = imageString {
            feedDict.setValue(imageString, forKey: "source_path")
        }
        feedDict.setValue(uploadType.rawValue, forKey: "source_type")
        if tumbString != nil {
            feedDict.setValue(tumbString, forKey: "thumb_path")
        }
        if postDescField.text != "say something" {
            feedDict.setValue(postDescField.text, forKey: "description")
        }
        if urlField.text != "URL" && urlField.text.replacingOccurrences(of: " ", with: "") != "" {
            feedDict.setValue(urlField.text, forKey: "url")
        }
        if postType == .homeFeed {
            feedDict.setValue(["Selfie"], forKey: "interests")
            feedDict.setValue(false, forKey: "is_adult_content")
        } else {
            if !selectedInterestArr.contains("Selfie") {
                selectedInterestArr.append("Selfie")
            }
            feedDict.setValue(selectedInterestArr, forKey: "interests")
            feedDict.setValue(adultContentBtn.isSelected, forKey: "is_adult_content")
        }

        // Post creater user detail
        feedDict.setValue(PWebService.sharedWebService.currentUser?.image_url, forKey: "user_image_url")
        feedDict.setValue(PWebService.sharedWebService.currentUser?.email ?? "", forKey: kEmailKey)
        switch postType {
        case .homeFeed:
            feedDict.setValue(PWebService.sharedWebService.currentUser?.user_id ?? "", forKey: "user_full_name")
        case .worldwideFeed:
            feedDict.setValue(PWebService.sharedWebService.currentUser?.worldwide_user_id ?? "", forKey: "user_full_name")
        case .newsSiteFeed:
            feedDict.setValue(PWebService.sharedWebService.currentUser?.news_site_name ?? "", forKey: "user_full_name")
        case .contentFeed:
            feedDict.setValue(PWebService.sharedWebService.currentUser?.content_account_name ?? "", forKey: "user_full_name")
        case .podcastFeed:
            feedDict.setValue(PWebService.sharedWebService.currentUser?.podcast_account_name ?? "", forKey: "user_full_name")
        }
        if editPost != 1 {
            PWebService.sharedWebService.createFeed(parameters: feedDict as! [String: AnyObject],
                                                    completion: { status, _, message in
                                                        if status == 100 {
                                                            Helper.sharedHelper.showGlobalAlertwithMessage(message!, vc: self, completion: {
                                                                self.navigationController?.popViewController(animated: true)
                                                            })
                                                        } else {
                                                            Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
                                                        }
            })
        } else {
            feedDict.setValue(postObj?.row_Key, forKey: "row_key")
            PWebService.sharedWebService.updatePost(parameters: feedDict as! [String: AnyObject],
                                                    rowKey: postObj!.row_Key!,
                                                    childName: kPOSTS_LIST_T,
                                                    completion: { status, _, message in

                                                        if status == 100 {
                                                            Helper.sharedHelper.showGlobalAlertwithMessage(message!, vc: self, completion: {
                                                                self.navigationController?.popViewController(animated: true)
                                                            })
                                                        } else {
                                                            Helper.sharedHelper.ShowAlert(str: message! as NSString, viewcontroller: self)
                                                        }
            })
        }
    }

    func videoSnapshot(vidURL: URL) -> UIImage? {
        let asset = AVURLAsset(url: vidURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch _ as NSError {
//            print("Image generation failed with error \(error)")
            return nil
        }
    }

    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch postType {
        case .homeFeed:
            if indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 5 {
                return 0
            }
        case .worldwideFeed, .contentFeed:
            if indexPath.row == 4 {
                return 0
            }
        case .newsSiteFeed:
            if indexPath.row == 4 || indexPath.row == 1 {
                return 0
            }
        case .podcastFeed:
            if indexPath.row == 4 || indexPath.row == 3 {
                return 0
            }
        }

        return UITableView.automaticDimension
    }
}

// MARK: - UIImagePickerControllerDelegate Methods

extension PCreatePostViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            if mediaType == "public.image" {
                if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    if let data = image.jpegData(compressionQuality: 1.0) {
                        // Here you get MB size
                        let size = Float(Double(data.count) / 1024 / 1024)

                        if size <= 15.00 || postType == .contentFeed {
                            uploadType = .image
                            postImageView.contentMode = .scaleAspectFit
                            postImageView.image = image

                            imageSelectionBtn.setTitle("", for: .normal)
                            picker.dismiss(animated: true, completion: nil)
                        } else {
                            picker.dismiss(animated: true, completion: nil)
                            Helper.sharedHelper.ShowAlert(str: "Image Size can't be more than 15 MB.", viewcontroller: self)
                        }
                    }
                }
            } else if mediaType == "public.movie" {
                if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                    if let data = try? Data(contentsOf: videoURL) {
                        let asset = AVAsset(url: videoURL)
                        let duration = asset.duration
                        let durationTime = CMTimeGetSeconds(duration)
                        let size = Float(Double(data.count) / 1024 / 1024)
                        if (size <= 30.00 || postType == .contentFeed || postType == .newsSiteFeed) && durationTime < 3600 {
                            uploadType = .video
                            videoData = data
                            postImageView.contentMode = .scaleAspectFit
                            postImageView.image = videoSnapshot(vidURL: videoURL)
                            imageSelectionBtn.setTitle("", for: .normal)
                            picker.dismiss(animated: true, completion: nil)
                        } else {
                            picker.dismiss(animated: true, completion: nil)
                            Helper.sharedHelper.ShowAlert(str: "Video Size can't be more than 30 MB.", viewcontroller: self)
                        }
                    }
                }
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextViewDelegate Methods

extension PCreatePostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = .darkGray
        if textView == postDescField && textView.text == "say something" {
            textView.text = ""
        } else if textView == urlField && textView.text == "URL" {
            textView.text = ""
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == postDescField && textView.text == "" {
            textView.text = "say something"
            textView.textColor = .lightGray
        } else if textView == urlField && textView.text == "" {
            textView.text = "URL"
            textView.textColor = .lightGray
        }
    }
}

extension PCreatePostViewController: IntersetsListDelegate {
    func selectedInterestArr(arr: [String]) {
        selectedInterestArr = arr
        interestView.reloadData()
    }
}

extension PCreatePostViewController: ZFTokenFieldDelegate, ZFTokenFieldDataSource {
    func tokenMarginInToken(in _: ZFTokenField!) -> CGFloat {
        return marginLbl
    }

    func lineHeightForToken(in _: ZFTokenField!) -> CGFloat {
        return tokenHeight
    }

    func numberOfToken(in _: ZFTokenField!) -> UInt {
        if selectedInterestArr.count > 0 {
            interestLbl.isHidden = true
        } else {
            interestLbl.isHidden = false
        }
        return UInt(selectedInterestArr.count)
    }

    func tokenField(_ tokenField: ZFTokenField!, viewForTokenAt index: UInt) -> UIView! {
        tokenField.textField.isEnabled = false
        var title = String()
        title = selectedInterestArr[NSInteger(index)]
        let testLbl1 = UILabel()
        testLbl1.text = " \(title) " // " + title! + "  "
        testLbl1.font = UIFont.systemFont(ofSize: 14)
        testLbl1.sizeToFit()

        var testLbl1Frame = testLbl1.frame
        testLbl1Frame.size.height = tokenHeight
        testLbl1.frame = testLbl1Frame

        testLbl1.layer.cornerRadius = marginLbl
        testLbl1.backgroundColor = MainCgColor
        testLbl1.textColor = UIColor.white
        testLbl1.clipsToBounds = true

        return testLbl1
    }
}

extension PCreatePostViewController: AudioRecorderDelegate {}
