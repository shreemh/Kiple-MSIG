//
//  KipleViewController.swift
//  AtilzeConsumer
//
//  Created by Adarsh on 28/07/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit
import Firebase
class KipleViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var kepleView: UIView!
    @IBOutlet weak var kepleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControle: UIPageControl!
    @IBOutlet weak var getStartedTap: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var getStartedNowBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    var titleText: [UILabel]?
    var subTitle: [UILabel]?
    let kipleObject  = [KipleCar]()
    var frame: CGRect = CGRect(x:0, y:0, width:0, height:0)
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        scrollView.delegate = self
        //Custom scroll View
        initialiseScrollView()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.hidesBackButton = true
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = UIColor.init(hexString: "00A3EA")
        // NAV TITLE
//        Utility.setTransparentNavigationBar(navigationController: navigationController)
    }
    /// Initialise the scrollviews
    func initialiseScrollView() {
        loginBtn.isHidden = true
        kepleLabel.isHidden = true
        getStartedNowBtn.isHidden = true
        for index in 0...3 {
            if index == 0 {
                if let walkthroughInitialView = Bundle.main.loadNibNamed("Walkthrough1", owner: self, options: nil)?[0] as? UIView {
                    var frame = walkthroughInitialView.frame
                    frame.origin.x = (UIScreen.main.bounds.size.width * CGFloat(index))
                    walkthroughInitialView.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: scrollView.frame.size.width, height: frame.size.height)
                    /// Add Subview
                    contentView.addSubview(walkthroughInitialView)
                }
            } else
                /// Init ScrollView
                if let walkthroughView = Bundle.main.loadNibNamed("Walkthrough", owner: self, options: nil)?[0] as? Walkthrough {
                    /// Set the frame of each view
                    var frame = walkthroughView.frame
                    frame.origin.x = (UIScreen.main.bounds.size.width * CGFloat(index))
                    walkthroughView.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: scrollView.frame.size.width, height: frame.size.height)
                    let titleText = walkthroughView.viewWithTag(1) as? UILabel
                    let subTitle = walkthroughView.viewWithTag(2) as? UILabel
                    let image = walkthroughView.viewWithTag(3) as? UIImageView
                    let bgImage = walkthroughView.viewWithTag(4) as? UIImageView
                    
                    if index == 1 {
                        titleText?.text = "Car Diagnostics"
                        subTitle?.text = "ConnectedCar's vehicle diagnostic ability allows you to identify the status of your car."
                        image?.image = UIImage.init(named: "initialScreen1")
                        bgImage?.image = UIImage.init(named: "initialBG1")
                    } else if index == 2 {
                        titleText?.text = "Trips Tracking"
                        subTitle?.text = "Benefit from ConnectedCar's trip tracker to keep track on your recent whereabouts."
                        image?.image = UIImage.init(named: "initialScreen2")
                        bgImage?.image = UIImage.init(named: "initialBG2")
                    } else if index == 3 {
                        titleText?.text = "Safety Score"
                        subTitle?.text = "The Safety Score feature keeps check on your driving behaviour."
                        image?.image = UIImage.init(named: "initialScreen3")
                        bgImage?.image = UIImage.init(named: "initialBG3")
                    }
                    /// Add Subview
                    contentView.addSubview(walkthroughView)
            }
        }
    }
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSize(width: (4 * UIScreen.main.bounds.size.width), height: 0)
    }
    @IBAction func getStartedNow(_ sender: Any) {
        Analytics.logEvent("get_started_now", parameters: nil)
    }
    @IBAction func changePage(_ sender: Any) {
        let x = CGFloat(pageControle.currentPage)*scrollView.frame.size.width
        self.scrollView.setContentOffset(CGPoint(x:x, y:0), animated: true)
    }
    func configurePageControle() {
        self.pageControle.currentPage = 0
        self.pageControle.currentPageIndicatorTintColor = UIColor(colorLiteralRed: 0/255, green: 115/255, blue: 164/255, alpha: 1)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x/scrollView.frame.size.width)
        pageControle.currentPage = Int(pageNumber)
        if pageControle.currentPage == 0 {
            loginBtn.isHidden = true
            kepleLabel.isHidden = true
        }else {
            loginBtn.isHidden = false
            kepleLabel.isHidden = false
        }
        
        if pageControle.currentPage == 3 {
            getStartedNowBtn.isHidden = false
        } else {
            getStartedNowBtn.isHidden = true
        }
    }
    
    @IBAction func getStartedNowBtnCall(_ sender: Any) {
    }
}
