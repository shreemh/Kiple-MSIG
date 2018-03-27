//
//  TabBarController.swift
//  AtilzeConsumer
//
// anoopkashok800 Created by Shree on 17/10/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
import Firebase

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setUp()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - SETUP
    
    func setUp() {
        let accountType = Utility.getLoginMode()
        if accountType == "OBDless" {
            let driveAndTrackNC = mainSB.instantiateViewController(withIdentifier: StoryBoardNC.driveAndTrack)
            var controllers = self.viewControllers
            controllers?[2] = driveAndTrackNC

            self.setViewControllers(controllers, animated: true)
            self.selectedIndex = 2  // DRIVE AND TRACK

            let driveNdTrack : UITabBarItem = tabBar.items![2]
            driveNdTrack.image = UIImage(named: "DriveTrack")?.withRenderingMode(.alwaysOriginal)
            driveNdTrack.selectedImage = UIImage(named: "DriveTrackSelected")?.withRenderingMode(.alwaysOriginal)
        }
    }
    
    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 0 {
            Analytics.logEvent("Home_Navigation", parameters: ["type" : "Home"])
        } else if tabBarController.selectedIndex == 1 {
            Analytics.logEvent("Home_Navigation", parameters: ["type" : "Trips"])
        } else if tabBarController.selectedIndex == 2 {
            let accType = Utility.getLoginMode()
            if accType == "OBD" {
                Analytics.logEvent("Home_Navigation", parameters: ["type" : "Car_Status"])
            } else {
                Analytics.logEvent("Home_Navigation", parameters: ["type" : "DriveAndTrack"])
            }
        } else {
            Analytics.logEvent("Home_Navigation", parameters: ["type" : "Settings"])
        }
        if Model.shared.isOngoingTrip {
            
        }
    }
}
