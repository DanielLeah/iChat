//
//  SettingsTableViewController.swift
//  iChat
//
//  Created by David Daniel Leah (BFS EUROPE) on 10/07/2019.
//  Copyright © 2019 David Daniel Leah (BFS EUROPE). All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    //MARK: Actions
    
    @IBAction func logOutTapped(_ sender: Any) {
        FUser.logOutCurrentUser { (success) in
            
            if success {
                self.showLoginView()
            }
        }
    }
    
    
    func showLoginView(){
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "welcome")
        self.present(mainView, animated: true, completion: nil)
    }
    
}
