//
//  FinishRegistrationViewController.swift
//  iChat
//
//  Created by David Daniel Leah (BFS EUROPE) on 08/07/2019.
//  Copyright © 2019 David Daniel Leah (BFS EUROPE). All rights reserved.
//

import UIKit
import ProgressHUD

class FinishRegistrationViewController: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    var email:String!
    var password:String!
    var avatarImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(email) and \(password)")
    }

    
    //MARK: Actions
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismissKeyboard()
        cleanTextFields()
        
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismissKeyboard()
        ProgressHUD.show("Registering...")
        
        if nameTextField.text != "" && surnameTextField.text != "" && countryTextField.text != "" && cityTextField.text != "" && phoneTextField.text != "" {
            FUser.registerUserWith(email: email!, password: password!, firstName: nameTextField.text!, lastName: surnameTextField.text!) { (error) in
                if error != nil {
                    ProgressHUD.dismiss()
                    ProgressHUD.showError(error?.localizedDescription)
                    return
                }
                print("sdada")
                self.registerUser()
            }
        }else{
            ProgressHUD.showError("All fields are required")
        }
    }
    
    
    //MARK: Helpers
    
    func registerUser(){
        let fullName = nameTextField.text! + " " + surnameTextField.text!
        
        var tempDic : Dictionary  = [kFIRSTNAME : nameTextField.text!,
                                     kLASTNAME : surnameTextField.text!,
                                     kFULLNAME : fullName,
                                     kCOUNTRY : countryTextField.text!,
                                     kCITY : cityTextField.text!,
        kPHONE : phoneTextField.text!] as [String : Any]
        
        if avatarImage == nil {
            imageFromInitials(firstName: nameTextField.text, lastName: surnameTextField.text) { (avatarInitials) in
                let avatarImg = avatarInitials.jpegData(compressionQuality: 0.7)
                let avatar = avatarImg!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                
                tempDic[kAVATAR] = avatar
                self.finishRegistration(withValues: tempDic)
            }
        }else{
            let avatarData = avatarImage?.jpegData(compressionQuality: 0.7)
            let avatar = avatarData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            tempDic[kAVATAR] = avatar
            
            self.finishRegistration(withValues: tempDic)
        }
    }
    
    func finishRegistration(withValues: [String:Any]){
        updateCurrentUserInFirestore(withValues: withValues) { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    ProgressHUD.showError(error!.localizedDescription)
                    print(error!.localizedDescription)
                }
            }
            // go to app
            ProgressHUD.dismiss()
            self.goToApp()
        }
    }
    
    func goToApp(){
        cleanTextFields()
        dismissKeyboard()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])
        
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
        
        self.present(mainView, animated: true, completion: nil)
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    func cleanTextFields(){
        nameTextField.text = ""
        surnameTextField.text = ""
        countryTextField.text = ""
        cityTextField.text = ""
        phoneTextField.text = ""
    }
}
