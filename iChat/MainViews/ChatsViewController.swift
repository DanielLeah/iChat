//
//  ChatsViewController.swift
//  iChat
//
//  Created by David Daniel Leah (BFS EUROPE) on 15/07/2019.
//  Copyright © 2019 David Daniel Leah (BFS EUROPE). All rights reserved.
//

import UIKit
import FirebaseFirestore

class ChatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RecentChatTableViewCellDelegate, UISearchResultsUpdating {

    

    @IBOutlet weak var tableView: UITableView!
    
    var recentChats: [NSDictionary] = []
    var filteredChats: [NSDictionary] = []
    
    var listener: ListenerRegistration!
    
    let searchController = UISearchController(searchResultsController: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        definesPresentationContext = true
        
        setTableViewHeader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadRecentChats()
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        listener.remove()
    }
    
    //MARK: Actions
    
    @IBAction func createChatTapped(_ sender: Any) {
        let userVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userTableView") as! UsersTableViewController
        
        self.navigationController?.pushViewController(userVC, animated: true)
    }
    
    //MARK: Tableview Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredChats.count
        }else {
            return recentChats.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecentChatTableViewCell
        
        cell.delegate = self
        
        var recent: NSDictionary!
        
        if searchController.isActive && searchController.searchBar.text != "" {
            recent = filteredChats[indexPath.row]
        }else {
            recent = recentChats[indexPath.row]
        }
        
        cell.generateCell(recentChat: recent, indexPath: indexPath)
        
        return cell
    }
    
    //MARK: TableView delegate
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var tempDict: NSDictionary!
        if searchController.isActive && searchController.searchBar.text != "" {
            tempDict = filteredChats[indexPath.row]
        }else {
            tempDict = recentChats[indexPath.row]
        }
        
        var muteTitle = "Unmute"
        var mute = false
        
        if (tempDict[kMEMBERSTOPUSH] as! [String]).contains(FUser.currentId()) {
            
            muteTitle = "Mute"
            mute = true
            
        }
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            
            self.recentChats.remove(at: indexPath.row)
            
            deleteRecentChat(recentChatDict: tempDict)
            
            self.tableView.reloadData()
        }
        
        let muteAction = UITableViewRowAction(style: .default, title: muteTitle) { (action, indexPath) in
            print("Mute \(indexPath)")
        }
        
        muteAction.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        
        return [deleteAction, muteAction]
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var recent: NSDictionary!
        if searchController.isActive && searchController.searchBar.text != "" {
            recent = filteredChats[indexPath.row]
        }else {
            recent = recentChats[indexPath.row]
        }
        
        //restart chat
        restartRecentChat(recent: recent)
        //show chat view
        
        let chatVC = ChatViewController()
        
        chatVC.hidesBottomBarWhenPushed = true
        chatVC.membersID = (recent[kMEMBERS] as! [String])
        chatVC.membersToPush = (recent[kMEMBERSTOPUSH] as! [String])
        chatVC.chatRoomID = (recent[kCHATROOMID] as! String)
        chatVC.titleName = (recent[kWITHUSERFULLNAME] as! String)
        navigationController?.pushViewController(chatVC, animated: true)
        
    }
    
    //MARK: Load recent chats
    
    func loadRecentChats() {
        
        listener = reference(.Recent).whereField(kUSERID, isEqualTo: FUser.currentId()).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else {return}
            
            self.recentChats = []
            
            if !snapshot.isEmpty {
                let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)]) as! [NSDictionary]
                for recent in sorted {
                    if recent[kLASTMESSAGE] as! String != "" && recent[kCHATROOMID] != nil && recent[kRECENTID] != nil {
                        self.recentChats.append(recent)
                    }
                }
                self.tableView.reloadData()
            }
        })
        
    }
    
    //MARK: Custom TableView Header
    
    func setTableViewHeader(){
        let width = UIScreen.main.bounds.width
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 45))
        
        let buttonView = UIView(frame: CGRect(x: 0, y: 5, width: width, height: 35))
        let groupButton = UIButton(frame: CGRect(x: width - 110, y: 10, width: 100, height: 20))
        groupButton.addTarget(self, action: #selector(self.groupButtonTapped), for: .touchUpInside)
        groupButton.setTitle("New Group", for: .normal)
        let buttonColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        groupButton.setTitleColor(buttonColor, for: .normal)
        
        let lineView = UIView(frame: CGRect(x: 0, y: headerView.frame.height - 1, width: width, height: 1))
        print("Line \(lineView.frame.width)")
        lineView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        buttonView.addSubview(groupButton)
        headerView.addSubview(buttonView)
        headerView.addSubview(lineView)
        tableView.tableHeaderView = headerView
    }
    
    @objc func groupButtonTapped(){
        print("Button Header tapped")
    }
    
    //MARK: RecentChatsCell Delegate
    
    func didTapAvatarImg(indexPath: IndexPath) {
        let recentChat = recentChats[indexPath.row]
        
        if recentChat[kTYPE] as! String == kPRIVATE {
            reference(.User).document(recentChat[kWITHUSERUSERID] as! String).getDocument { (snapshot, error) in
                
                guard let snapshot = snapshot else {return}
                
                if snapshot.exists {
                    let userDict = snapshot.data()! as NSDictionary
                    
                    let tempUser = FUser(_dictionary: userDict)
                    
                    self.showUserProfile(user: tempUser)
                }
            }
        }
        
    }
    
    func showUserProfile(user: FUser){
        
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileView") as! ProfileViewTableViewController
        
        profileVC.user = user
        
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    //Mark: Search Controller functions
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All"){
        filteredChats =  recentChats.filter { (chat) -> Bool in
            return (chat[kWITHUSERFULLNAME] as! String).lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
}
