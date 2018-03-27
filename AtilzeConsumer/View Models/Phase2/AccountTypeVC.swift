//
//  AccountTypeVC.swift
//  AtilzeConsumer
//
//  Created by Shree on 17/10/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit

class AccountTypeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func withOBDBtnCalled(_ sender: Any) {
        UserDefaults.standard.set("OBD", forKey: "VW.Consumer.loginMode")
        let loginVC = secondSB.instantiateViewController(withIdentifier: StoryBoardVC.login)
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    @IBAction func withPhoneBtnCalled(_ sender: Any) {
        UserDefaults.standard.set("OBDless", forKey: "VW.Consumer.loginMode")
        let loginVC = secondSB.instantiateViewController(withIdentifier: StoryBoardVC.login)
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
}
