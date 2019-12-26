//
//  DesignableUITextField.swift
//  Peps
//
//  Created by Shubham Garg on 20/05/19.
//  Copyright © 2019 KP Tech. All rights reserved.
//

import Foundation
import JVFloatLabeledTextField
import UIKit

@IBDesignable
class DesignableUITextField: JVFloatLabeledTextField {
    // Provides left padding for images
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftPadding
        return textRect
    }

    @IBInspectable var leftImage: UIImage? {
        didSet {
//            updateView()
        }
    }

    @IBInspectable var leftPadding: CGFloat = 0 {
        didSet {
            leftViewMode = UITextField.ViewMode.always
        }
    }

    @IBInspectable var color: UIColor = UIColor.lightGray {
        didSet {
//            updateView()
        }
    }

    func updateView() {
        if let image = leftImage {
            leftViewMode = UITextField.ViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 10, width: 30, height: 50))
            imageView.contentMode = .left
            imageView.image = image
            // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
            imageView.tintColor = color
            leftView = imageView
        } else {
            leftViewMode = UITextField.ViewMode.never
            leftView = nil
        }

        // Placeholder text color
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ? placeholder! : "", attributes: [NSAttributedString.Key.foregroundColor: color])
    }
}
