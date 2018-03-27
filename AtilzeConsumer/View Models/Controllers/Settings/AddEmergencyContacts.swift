//
//  AddEmergencyContacts.swift
//  AtilzeConsumer
//
//  Created by Shree on 29/11/17.
//  Copyright © 2017 Cognitive. All rights reserved.
//

import UIKit

class AddEmergencyContacts: UIViewController {

    var isAddContact : Bool?
    @IBOutlet weak var addContactView: UIView!
    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var contact: UILabel!
    @IBOutlet weak var addContactBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isAddContact! {
            contactView.isHidden = true
            addContactView.isHidden = false
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addEditDelete))
            addContactView.addGestureRecognizer(tap)
        } else {
            contactView.isHidden = false
            addContactView.isHidden = true
            name.text = Model.shared.profileDict["emergency_name"]
            contact.text = Model.shared.profileDict["emergency_contact"]
//            addContactBtn.addTarget(self, action: #selector(addEditDelete), for: .touchUpInside)
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addEditDelete))
            contactView.addGestureRecognizer(tap)
        }
    }
    
    override func viewWillLayoutSubviews() {
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
     
    }
    
    func addEditDelete() {
        
        guard let addEditDeleteVC = mainSB.instantiateViewController(withIdentifier: "AddOrEditEmergencyContactVC") as? AddOrEditEmergencyContactVC else {
            return
        }
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(addEditDeleteVC, animated: true)
    }
}
