//
//  UsersTableViewController.swift
//  iChat
//
//  Created by David Daniel Leah (BFS EUROPE) on 12/07/2019.
//  Copyright © 2019 David Daniel Leah (BFS EUROPE). All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class UsersTableViewController: UITableViewController, UISearchResultsUpdating, UserTableViewCellDelegate {

    var allUsers : [FUser] = []
    var filteredUsers : [FUser] = []
    var allUsersGroupped = NSDictionary() as! [String:[FUser]]
    var sectionTitleList : [String] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Users"
        navigationItem.largeTitleDisplayMode = .never
        
        tableView.tableFooterView = UIView()
        
        navigationItem.searchController = searchController
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        loadUsers(filter: kCITY)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive && searchController.searchBar.text != ""{
            return 1
        }else{
            return allUsersGroupped.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchController.isActive && searchController.searchBar.text != ""{
            return filteredUsers.count
        }else {
            let sectionTitle = self.sectionTitleList[section]
            
            let users = self.allUsersGroupped[sectionTitle]
            
            return users!.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserTableViewCell
        
        var user : FUser
        
        if searchController.isActive && searchController.searchBar.text != ""{
            user = filteredUsers[indexPath.row]
        }else{
            let sectionTitle = self.sectionTitleList[indexPath.section]
            
            let users = self.allUsersGroupped[sectionTitle]
            print("section title is: \(sectionTitle)")
            user = users![indexPath.row]
        }
        
        cell.generateCellWith(fUser: user, indexPath: indexPath)
        
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive && searchController.searchBar.text != ""{
            return ""
        }else {
            return sectionTitleList[section]
        }
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchController.isActive && searchController.searchBar.text != ""{
            return nil
        }else {
            return self.sectionTitleList
        }
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        var user : FUser
        
        if searchController.isActive && searchController.searchBar.text != ""{
            user = filteredUsers[indexPath.row]
        }else{
            let sectionTitle = self.sectionTitleList[indexPath.section]
            
            let users = self.allUsersGroupped[sectionTitle]
            
            user = users![indexPath.row]
        }
        
        startPrivateChat(user1: FUser.currentUser()!, user2: user)
        
    }
    
    func loadUsers(filter: String){
        ProgressHUD.show()
        var query: Query!
        
        switch filter {
        case kCITY:
            query = reference(.User).whereField(kCITY, isEqualTo: FUser.currentUser()!.city).order(by: kFIRSTNAME, descending: false)
        case kCOUNTRY:
            query = reference(.User).whereField(kCOUNTRY, isEqualTo: FUser.currentUser()!.country).order(by: kFIRSTNAME, descending: false)
        default:
            query = reference(.User).order(by: kFIRSTNAME, descending: false)
        }
        
        query.getDocuments { (snapshot, error) in
            self.allUsers = []
            self.sectionTitleList = []
            self.allUsersGroupped = [:]
            
            if error != nil {
                print(error!.localizedDescription)
                ProgressHUD.dismiss()
                self.tableView.reloadData()
                return
            }
            
            guard let snapshot = snapshot else {
                ProgressHUD.dismiss()
                return
            }
            
            if !snapshot.isEmpty {
                for userDict in snapshot.documents {
                    
                    let userDictionary = userDict.data() as NSDictionary
                    let fUser = FUser(_dictionary: userDictionary)
                    
                    if fUser.objectId != FUser.currentId() {
                        self.allUsers.append(fUser)
                    }
                    
                    
                }
                
                self.splitDataIntoSections()
                self.tableView.reloadData()
                
                ProgressHUD.dismiss()
                
            }
        }
        
    }
    
    //MARK: IBActions
    
    @IBAction func filterSegmentValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            loadUsers(filter: kCITY)
        case 1:
            loadUsers(filter: kCOUNTRY)
        case 2:
            loadUsers(filter: "")
        default:
            return
        }
    }
    
    
    //Mark: Search Controller functions
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
        
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All"){
        filteredUsers = allUsers.filter { (user) -> Bool in
            return user.firstname.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    fileprivate func splitDataIntoSections(){
        var sectionTitle : String = ""
        
        for i in 0..<self.allUsers.count {
            let currentUser = self.allUsers[i]
            
            let firstChr = currentUser.firstname.first!
            
            let firstChrStr = "\(firstChr)"
            
            if firstChrStr != sectionTitle {
                sectionTitle = firstChrStr
                self.allUsersGroupped[sectionTitle] = []
                
                self.sectionTitleList.append(sectionTitle)
            }
            
            self.allUsersGroupped[firstChrStr]?.append(currentUser)
        }
    }
    
    //MARK: User Table View Cell Delegate
    func didTapAvatarImg(indexPath: IndexPath) {
        
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileView") as! ProfileViewTableViewController
        
        var user : FUser
        
        if searchController.isActive && searchController.searchBar.text != ""{
            user = filteredUsers[indexPath.row]
        }else{
            let sectionTitle = self.sectionTitleList[indexPath.section]
            
            let users = self.allUsersGroupped[sectionTitle]
            
            user = users![indexPath.row]
        }
        
        profileVC.user = user
        
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
}
