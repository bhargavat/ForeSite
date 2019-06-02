//
//  AuthController.swift
//  ForeSite
//
//  Created by Bhargava on 4/6/19.
//  Copyright © 2019 Bhargava. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import TextFieldEffects
import SwiftyJSON

class AuthController: UIViewController, UITextFieldDelegate{
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet var loginView: UIView!
    @IBOutlet var registerView: UIView!
    
    var tapGesture = UITapGestureRecognizer()
    var passHidden = true
    var invalidRegistrationFields:[String] = []
    
    //login fields
    @IBOutlet weak var usernameField: HoshiTextField!
    @IBOutlet weak var passwordField: HoshiTextField!
    
    //register fields
    @IBOutlet weak var firstnameField: HoshiTextField!
    @IBOutlet weak var lastnameField: HoshiTextField!
    @IBOutlet weak var emailField: HoshiTextField!
    @IBOutlet weak var phoneField: HoshiTextField!
    @IBOutlet weak var r_usernameField: HoshiTextField!
    @IBOutlet weak var r_passwordField: HoshiTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch self.restorationIdentifier {
        case "loginView":
            self.usernameField.delegate = self
            self.passwordField.delegate = self
            self.usernameField.text = "ctarng"
            self.passwordField.text = "abc"
        case "registerView":
            self.firstnameField.delegate = self
            self.lastnameField.delegate = self
            self.emailField.delegate = self
            self.phoneField.delegate = self
            self.r_usernameField.delegate = self
            self.r_passwordField.delegate = self
        default:
            break
        }
        self.hideKeyboard()
        

    }
    
    
    @IBAction func loginClicked(_ sender: UIButton) {
        let usernameInput = usernameField.text
        let passwordInput = passwordField.text
        
        if (usernameInput != "" && passwordInput != "" && Connectivity.isConnectedToInternet){
            let parameters: Parameters = ["user_name":usernameInput!, "password": passwordInput!.md5()]
            
            AF.request(base_url + "/foresite/login", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{ response in
                
                if (response.data != nil){
                    do{
                        let json = try JSON(data: response.data!)
                        if(json["response"] == "success"){
                            username = usernameInput!

                            self.performSegue(withIdentifier: "EventListSegue", sender: self)
                        }else{
                            let alertController = UIAlertController(title: "Login Failed", message:
                                "Incorrect login credentials", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .default){
                                    UIAlertAction in
                                    self.usernameField.text = ""
                                    self.passwordField.text = ""
                                })
                            
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }catch{
                        print("ERROR: Failed to cast request to JSON format")
                    }
                }else{
                    let alertController = UIAlertController(title: "Server Unavailable", message:
                        "Please try again", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }else{
            let alertController = UIAlertController(title: "Error", message:
                "Please enter username and password", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    @IBAction func hidePassword(_ sender: Any) {
        if(!passHidden){ //hide password
            r_passwordField.isSecureTextEntry = true
            passHidden = true
        }else if(r_passwordField.text != ""){
            r_passwordField.isSecureTextEntry = false
            passHidden = false
        }
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if(username != "" || identifier == "RegisterSegue"
            || identifier == "DismissRegisterSegue"){
            return true
        }
        return false
    }
    
    @IBAction func registerNewUser(_ sender: Any) {
        if(isvalidRegistrationInput() == false){
            addWarningToFields()
            let alertController = UIAlertController(title: "Registration Failed", message:
                "Please fix the highlighted fields", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true, completion: nil)
        }else{
            let parameters: Parameters =
                ["first_name": firstnameField.text!,
                 "last_name": lastnameField.text!,
                 "email": emailField.text!,
                 "phone_number": phoneField.text!,
                 "user_name": r_usernameField.text!,
                 "password": r_passwordField.text!.md5()]
            
            if(isvalidRegistrationInput() == true){
                if(Connectivity.isConnectedToInternet){
                    AF.request(base_url + "/foresite/createUser", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{ response in
                        
                        do{
                            let json = try JSON(data: response.data!)
                            
                            if(json["response"] == "success"){
                                
                                let alertController = UIAlertController(title: "Success", message:
                                    "Registration is successful", preferredStyle: .alert)
                                
                                self.present(alertController, animated: true, completion: {
                                    let when = DispatchTime.now() + 4
                                    DispatchQueue.main.asyncAfter(deadline: when){
                                        self.performSegue(withIdentifier: "DismissRegisterSegue", sender: self)
                                    }

                                })
                                
                                
                            }else{
                                let errorMsg = json["message"].string
                                let alertController = UIAlertController(title: "Registration Failed", message:
                                    errorMsg, preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: "OK", style: .default))
                                
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }catch{
                            print("ERROR: Failed to cast request to JSON format")
                        }
                    }
                }
            }
        }
    }
    
    func isvalidRegistrationInput() -> Bool{
        invalidRegistrationFields.removeAll()
        if(firstnameField.text! == ""){
            invalidRegistrationFields.append("First Name")
        }
        if(lastnameField.text! == ""){
            invalidRegistrationFields.append("Last Name")
        }
        if(emailField.text!.isEmail == false){
            invalidRegistrationFields.append("Email")
        }
        if(phoneField.text!.isPhoneNumber == false){
            invalidRegistrationFields.append("Phone Number")
        }
        if(r_usernameField.text!.count < 3){
            invalidRegistrationFields.append("Username")
            }
            if(r_passwordField.text!.count < 3){
                invalidRegistrationFields.append("Password")
            }
        
            if(invalidRegistrationFields.count > 0){
                return false
            }
            return true
        }
    
        func resetFieldColors(){
            let placeholderColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.9568627451, alpha: 1)
            let activeColor = #colorLiteral(red: 0.03833928332, green: 0.3575392365, blue: 0.3587242961, alpha: 1)
            let inactiveColor = #colorLiteral(red: 0.2588235294, green: 0.7529411765, blue: 0.7921568627, alpha: 1)
            
            firstnameField.placeholderColor = placeholderColor
            firstnameField.borderActiveColor = activeColor
            firstnameField.borderInactiveColor = inactiveColor
 
            lastnameField.placeholderColor = placeholderColor
            lastnameField.borderActiveColor = activeColor
            lastnameField.borderInactiveColor = inactiveColor

            emailField.placeholderColor = placeholderColor
            emailField.borderActiveColor = activeColor
            emailField.borderInactiveColor = inactiveColor

            phoneField.placeholderColor = placeholderColor
            phoneField.borderActiveColor = activeColor
            phoneField.borderInactiveColor = inactiveColor

            r_usernameField.placeholderColor = placeholderColor
            r_usernameField.borderActiveColor = activeColor
            r_usernameField.borderInactiveColor = inactiveColor

            r_passwordField.placeholderColor = placeholderColor
            r_passwordField.borderActiveColor = activeColor
            r_passwordField.borderInactiveColor = inactiveColor
        }
    
        func addWarningToFields() {
            resetFieldColors()
            let warnColor = #colorLiteral(red: 0.9322057424, green: 0.009281606348, blue: 0.01016797919, alpha: 1)
            for field in invalidRegistrationFields {
                switch field {
                case "First Name":
                    firstnameField.placeholderColor = warnColor
                    firstnameField.borderActiveColor = warnColor
                    firstnameField.borderInactiveColor = warnColor
                case "Last Name":
                    lastnameField.placeholderColor = warnColor
                    lastnameField.borderActiveColor = warnColor
                    lastnameField.borderInactiveColor = warnColor
                case "Email":
                    emailField.placeholderColor = warnColor
                    emailField.borderActiveColor = warnColor
                    emailField.borderInactiveColor = warnColor
                case "Phone Number":
                    phoneField.placeholderColor = warnColor
                    phoneField.borderActiveColor = warnColor
                    phoneField.borderInactiveColor = warnColor
                case "Username":
                    r_usernameField.placeholderColor = warnColor
                    r_usernameField.borderActiveColor = warnColor
                    r_usernameField.borderInactiveColor = warnColor
                case "Password":
                    r_passwordField.placeholderColor = warnColor
                    r_passwordField.borderActiveColor = warnColor
                    r_passwordField.borderInactiveColor = warnColor
                default:
                    return
            }
        }
    }
}
