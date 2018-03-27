//
//  CustomTextField.swift
//  AtilzeConsumer
//
//  Created by Shree on 02/08/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 5)
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.layer.borderColor = UIColor.init(hexString: "B7B7B7").cgColor
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        self.layer.masksToBounds = true
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }

}
