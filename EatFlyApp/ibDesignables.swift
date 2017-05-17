////
////  ibDesignables.swift
////  EatFlyApp
////
////  Created by Marlon Pavanello on 13/05/2017.
////  Copyright © 2017 Marlon Pavanello. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//@IBDesignable
//class DesignableUITextField: UITextField {
//    
//    // MARK: - Overrides
//    
//    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
//        var frame = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width * 0.6, height: bounds.size.height))
//        
//        if #available(iOS 9.0, *) {
//            if UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft {
//                frame.origin = CGPoint(x: bounds.size.width - frame.size.width, y: frame.origin.y)
//            }
//        }
//        
//        return frame.insetBy(dx: textFieldInsets.x, dy: textFieldInsets.y)
//    }
//    
//    override open func textRect(forBounds bounds: CGRect) -> CGRect {
//        return editingRect(forBounds: bounds)
//    }
//    
//    // Provides left padding for images
//    override open func leftViewRect(forBounds bounds: CGRect) -> CGRect {
//        var textRect = super.leftViewRect(forBounds: bounds)
//        textRect.origin.x += leadingPadding
//        return textRect
//    }
//    
//    // Provides right padding for images
//    override open func rightViewRect(forBounds bounds: CGRect) -> CGRect {
//        var textRect = super.rightViewRect(forBounds: bounds)
//        textRect.origin.x -= leadingPadding
//        return textRect
//    }
//    
//    @IBInspectable var leadingImage: UIImage? {
//        didSet {
//            updateView()
//        }
//    }
//    
//    @IBInspectable var leadingPadding: CGFloat = 0
//    
//    @IBInspectable var color: UIColor = UIColor.lightGray {
//        didSet {
//            updateView()
//        }
//    }
//    
//    @IBInspectable var rtl: Bool = false {
//        didSet {
//            updateView()
//        }
//    }
//    
//    func updateView() {
//        rightViewMode = UITextFieldViewMode.never
//        rightView = nil
//        leftViewMode = UITextFieldViewMode.never
//        leftView = nil
//        
//        if let image = leadingImage {
//            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
//            imageView.image = image
//            // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
//            imageView.tintColor = color
//            
//            if rtl {
//                rightViewMode = UITextFieldViewMode.always
//                rightView = imageView
//            } else {
//                leftViewMode = UITextFieldViewMode.always
//                leftView = imageView
//            }
//        }
//        
//        // Placeholder text color
//        attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[NSForegroundColorAttributeName: color])
//    }
//
//    
//    }
