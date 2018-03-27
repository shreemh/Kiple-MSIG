//
//  RoadsideAssistDetailVC.swift
//  AtilzeConsumer
//
//  Created by Shree on 30/11/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit

class RoadsideAssistDetailVC: UIViewController {

    var requestID : Int = 0
    @IBOutlet weak var requestIDLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillLayoutSubviews() {
        navigationController?.navigationItem.hidesBackButton = true
    }
    
    func setUp() {
        requestIDLbl.text = "Request ID:\(String(requestID))"
        navigationController?.navigationItem.hidesBackButton = true
    }
    
    
    
    @IBAction func backToHomeBtnCall(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
}
