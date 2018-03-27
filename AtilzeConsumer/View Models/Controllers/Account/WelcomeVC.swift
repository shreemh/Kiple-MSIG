//
//  WelcomeVC.swift
//  AtilzeCunsumer
//
//  Created by Shree on 24/08/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit

class WelcomeVC: UIViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var welcomeMsg: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.hidesBackButton = true
        Utility.setTransparentNavigationBar(navigationController: navigationController)
        navigationItem.titleView = Utility.getKipleCarAttributedLabel()
    }

    // MARK: - SETUP
    func setUpView() {
        //TITLE 
        titleLbl.text =  Model.shared.isFromForgotPW ? "Password Reset Complete!" : "Welcome!"
        welcomeMsg.text = Model.shared.isFromForgotPW ? "Your password reset is complete.\n you can now login with new password." : "Your account setup is now complete. Login now to start tracking your driving statistics and car status."
        // RESET THE VALUE HERE
        Model.shared.isFromForgotPW = false
        // NAV TITLE
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    override func viewWillLayoutSubviews() {
    }
    // MARK: - UIBUTTON ACTIONS
    @IBAction func loginBtnCal(_ sender: Any) {
        
    }
}
