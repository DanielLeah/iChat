//
//  ProfileViewTableViewController.swift
//  iChat
//
//  Created by David Daniel Leah (BFS EUROPE) on 17/07/2019.
//  Copyright © 2019 David Daniel Leah (BFS EUROPE). All rights reserved.
//

import UIKit

class ProfileViewTableViewController: UITableViewController {

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var phoneNoLabel: UILabel!
    @IBOutlet weak var callButtonOutlet: UIButton!
    @IBOutlet weak var messageButtonOutlet: UIButton!
    @IBOutlet weak var blockButtonOutlet: UIButton!
    @IBOutlet weak var avatarImage: UIImageView!
    
    //variables
    var user: FUser?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 30
    }
    //MARK: Actions
    
    @IBAction func callTapped(_ sender: Any) {
    }
    @IBAction func messageTapped(_ sender: Any) {
    }
    @IBAction func blockTapped(_ sender: Any) {
        
        var currentBlockedIDs = FUser.currentUser()!.blockedUsers
        
        if currentBlockedIDs.contains(user!.objectId) {
            let index = currentBlockedIDs.firstIndex(of: user!.objectId)!
            currentBlockedIDs.remove(at: index)
        }else {
            currentBlockedIDs.append(user!.objectId)
        }
        
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID : currentBlockedIDs]) { (error) in
            if error != nil {
                print("error updating user \(error!.localizedDescription)")
                return
            }
            self.updateBlockStatus()
        }
        
    }
    

    //Functions
    
    func setupUI(){
        if user != nil {
            self.title = "Profile"
            
            fullNameLabel.text = user!.fullname
            phoneNoLabel.text = user!.phoneNumber
            
            updateBlockStatus()
            
            imageFromData(pictureData: user!.avatar) { (avatarImage) in
                if avatarImage != nil {
                    self.avatarImage.image = avatarImage!.circleMasked
                }
            }
        }
    }
    
    func updateBlockStatus(){
        
        if user!.objectId != FUser.currentId() {
            blockButtonOutlet.isHidden = false
            messageButtonOutlet.isHidden = false
            callButtonOutlet.isHidden = false
        }else {
            blockButtonOutlet.isHidden = true
            messageButtonOutlet.isHidden = true
            callButtonOutlet.isHidden = true
        }
        
        if FUser.currentUser()!.blockedUsers.contains(user!.objectId) {
            blockButtonOutlet.setTitle("Unblock user", for: .normal)
        }else {
            blockButtonOutlet.setTitle("Block user", for: .normal)
        }
        
    }
    
}
