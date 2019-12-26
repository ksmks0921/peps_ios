//
//  Helper.swift
//  Peps
//
//  Created by Sivaprasadreddy Puli on 22/07/17.
//  Copyright © 2017 KP Tech. All rights reserved.
//

import UIKit

class Helper: NSObject {
    static let sharedHelper = Helper()
    var appDel: AppDelegate

    var loaderViewController: UIViewController?
    override init() {
        appDel = UIApplication.shared.delegate as! AppDelegate
    }

    func validateEmailWithString(_ checkString: NSString) -> Bool {
        let laxString = ".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*" as String
        let emailTest = NSPredicate(format: "SELF MATCHES %@", laxString) as NSPredicate
        return emailTest.evaluate(with: checkString)
    }

//    func md5(string: String) -> Data {
//        let messageData = string.data(using:.utf8)!
//        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
//
//        _ = digestData.withUnsafeMutableBytes {digestBytes in
//            messageData.withUnsafeBytes {messageBytes in
//                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
//            }
//        }
//
//        return digestData
//    }

    // MARK: - nav bar change

    public func setNavigationBar() {
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = UIColor(red: 45.0 / 255.0, green: 75.0 / 255.0, blue: 148.0 / 255.0, alpha: 1.0)
        let titleDict: NSDictionary = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(20.0), weight: UIFont.Weight.medium)]
        UINavigationBar.appearance().titleTextAttributes = titleDict as? [NSAttributedString.Key: Any]
        UINavigationBar.appearance().isTranslucent = false
        let image = UIImage(named: "back")
        let backArrowImage = image
        let renderedImage = backArrowImage?.withRenderingMode(.alwaysOriginal)
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000, vertical: 0), for: UIBarMetrics.default)
        UINavigationBar.appearance().backIndicatorImage = renderedImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = renderedImage
    }

    // MARK: - Make view Circular

    public func setDottedBorder(view: UIView) {
        let yourViewBorder = CAShapeLayer()
        yourViewBorder.strokeColor = UIColor.lightGray.cgColor
        yourViewBorder.lineDashPattern = [2, 2]
        yourViewBorder.frame = view.bounds
        yourViewBorder.fillColor = nil
        yourViewBorder.path = UIBezierPath(rect: view.bounds).cgPath
        view.layer.addSublayer(yourViewBorder)
    }

    func showGlobalAlertwithMessage(_ str: String) {
        DispatchQueue.main.async(execute: {
            let window: UIWindow = UIApplication.shared.windows.last!
            let alertView = UIAlertController(title: "Alert", message: str as String, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            window.rootViewController!.present(alertView, animated: true, completion: nil)
        })
    }

    func showGlobalAlertwithMessage(_ str: String, vc: UIViewController, completion: (() -> Swift.Void)? = nil) {
        DispatchQueue.main.async(execute: {
            let alertView = UIAlertController(title: "Alert", message: str as String, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ -> Void in

                completion?()
            }))
            vc.present(alertView, animated: true, completion: nil)
        })
    }

    class func dropShadow(view: UIView, upOrDown: Bool) {
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 0.5

        if upOrDown {
            view.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        } else {
            view.layer.shadowOffset = CGSize(width: -1.0, height: 1.0)
        }
        view.layer.shadowRadius = 2
        view.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
    }

    class func dateStringFromInt(dateInt: TimeInterval?, formatter _: String = "dd MMM") -> String? {
        if let dataI = dateInt {
            let converted = NSDate(timeIntervalSince1970: TimeInterval(dataI / 1000))
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = NSTimeZone.local
            dateFormatter.dateFormat = "dd MMM"
            let time = dateFormatter.string(from: converted as Date)
            return time
        }

        return ""
    }

    func showLoader() {
        if let window = UIApplication.shared.windows.first {
            loaderViewController?.view.bounds = UIScreen.main.bounds
            window.addSubview((loaderViewController?.view)!)
        }
    }

    func hideLoader() {
        loaderViewController?.view.removeFromSuperview()
    }

    func showGlobalHUD(title: NSString, view: UIView) {
        let HUD = MBProgressHUD.showAdded(to: view, animated: true)
        HUD.label.text = title as String
    }

    func dismissHUD(view: UIView) {
        MBProgressHUD.hide(for: view, animated: true)
    }

    func isNetworkAvailable() -> Bool {
        let rechability = Reachability()

        if (rechability?.isReachable)! {
            return true
        } else {
            return false
        }
    }

    func ShowAlert(str: NSString, viewcontroller: UIViewController) {
        let alertView = UIAlertController(title: "Al2gether", message: str as String, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        viewcontroller.navigationController?.present(alertView, animated: true, completion: nil)
    }

    func generateName() -> String {
        let date = Date()
        let formater = DateFormatter()
        formater.dateFormat = "dd:MM:yyyy:mm:ss:SSS"
        let DateStr = formater.string(from: date) as String
        return DateStr.replacingOccurrences(of: ":", with: "")
    }

    func getCreateddate(createddate: Int) -> String {
        let createdAt = NSDate(timeIntervalSince1970: TimeInterval(createddate / 1000))

        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd MMM yyyy hh:mm a"

        let dateString = dateFormatterPrint.string(from: createdAt as Date)

        return dateString
    }
}

//extension MutableCollection where Indices.Iterator.Element == Index {
//    /// Shuffles the contents of this collection.
//    mutating func shuffle() {
//        let c = count
//        guard c > 1 else { return }
//
//        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
//            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
//            guard d != 0 else { continue }
//            let i = index(firstUnshuffled, offsetBy: d)
//            swapAt(firstUnshuffled, i)
//        }
//    }
//}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

extension String {
    func stringKey() -> String {
        var key = replacingOccurrences(of: "@", with: "")
        key = key.replacingOccurrences(of: ".", with: "")
        return key
    }
}

class RRButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        let spacing = CGFloat(10)
        let spacing1 = CGFloat(15)
        imageEdgeInsets = UIEdgeInsets(top: spacing1, left: spacing, bottom: spacing1, right: spacing)
    }
}
