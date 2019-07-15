//
//  WelcomeViewController.swift
//  iChat
//
//  Created by David Daniel Leah (BFS EUROPE) on 04/07/2019.
//  Copyright © 2019 David Daniel Leah (BFS EUROPE). All rights reserved.
//

import UIKit
import ProgressHUD
class WelcomeViewController: UIViewController {


    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    //MARK: Actions
    @IBAction func loginTapped(_ sender: Any) {
        dismissKeyboard()
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            loginUser()
        }else{
            ProgressHUD.showError("Email and Password is missing!")
        }
        
    }
    @IBAction func registerTapped(_ sender: Any) {
        dismissKeyboard()
        if emailTextField.text != "" && passwordTextField.text != "" && repeatTextField.text != ""{
            if passwordTextField.text == repeatTextField.text {
                registerUser()
            }else{
                ProgressHUD.showError("Passwords don't match!")
            }
            
        }else{
            ProgressHUD.showError("All fields are required!")
        }
    }
    @IBAction func oneTapRecognizer(_ sender: Any) {
        dismissKeyboard()
    }
    
    
    
    
    //MARK: Helpers
    
    func loginUser(){
        ProgressHUD.show("Login..")
        FUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            self.goToApp()
        }
    }
    
    func registerUser(){
        performSegue(withIdentifier: "welcomeToFinishReg", sender: self)
        
        cleanTextFields()
        dismissKeyboard()
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    func cleanTextFields(){
        emailTextField.text = ""
        passwordTextField.text = ""
        repeatTextField.text = ""
    }
    
    //MARK: Go to app
    func goToApp(){
        ProgressHUD.dismiss()
        
        cleanTextFields()
        dismissKeyboard()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])
        
        //Present
        cleanTextFields()
        dismissKeyboard()
        
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
        
        self.present(mainView, animated: true, completion: nil)
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "welcomeToFinishReg"{
            let vc = segue.destination as! FinishRegistrationViewController
            vc.email = emailTextField.text!
            vc.password = passwordTextField.text!
        }
    }
    
}
