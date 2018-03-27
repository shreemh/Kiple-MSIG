//
//  TripsNotVC.swift
//  AtilzeCunsumer
//
//  Created by Adarsh on 22/09/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit

class TripsNotVC: UIViewController {
    @IBOutlet weak var carDescription: UILabel!
    @IBOutlet weak var titlLbl: UILabel!
    var titleText : String = String()
    var details : String = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func setup() {
//        titlLbl.text = titleText
//        carDescription.text = details
    }
}
