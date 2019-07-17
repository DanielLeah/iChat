//
//  ChatsViewController.swift
//  iChat
//
//  Created by David Daniel Leah (BFS EUROPE) on 15/07/2019.
//  Copyright © 2019 David Daniel Leah (BFS EUROPE). All rights reserved.
//

import UIKit

class ChatsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    //MARK: Actions
    
    @IBAction func createChatTapped(_ sender: Any) {
        let userVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userTableView") as! UsersTableViewController
        
        self.navigationController?.pushViewController(userVC, animated: true)
    }
    
    
}
