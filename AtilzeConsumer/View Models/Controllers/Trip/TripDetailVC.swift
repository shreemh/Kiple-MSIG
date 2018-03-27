//
//  TripDetailVC.swift
//  AtilzeCunsumer
//
//  Created by Shree on 07/08/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
import MBCircularProgressBar

class TripDetailVC: UIViewController {

    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var startAddress: UILabel!
    @IBOutlet weak var endAddress: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var fuelEfficincy: UILabel!
    @IBOutlet weak var safetyScore: MBCircularProgressBarView!
    @IBOutlet var progressViewCollection: [MBCircularProgressBarView]!
    var tripDetails: TripModelView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - SETUP
    func setUpView() {
        
    }
    
    
    
    
    
    
    
    
    
    
}
