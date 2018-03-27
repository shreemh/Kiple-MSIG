//
//  SimpleTextField.swift
//  AtilzeConsumer
//
//  Created by Shree on 22/12/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit

class SimpleTextField: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 5)
    
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
