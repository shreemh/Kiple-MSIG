//
//  CustomShadeView.swift
//  AtilzeConsumer
//
//  Created by Shree on 02/08/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit

class CustomShadeView: UIView {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 2
     //   self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    }
}
