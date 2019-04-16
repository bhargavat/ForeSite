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
        
        if (usernameInput != "" && passwordInput != ""){
            let parameters: Parameters = ["user_name":usernameInput!, "password": passwordInput!.md5()]
            
            AF.request("http://127.0.0.1:5000/foresite/login", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{ response in
                
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
        print(my_string)
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
                AF.request("http://127.0.0.1:5000/foresite/createUser", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{ response in
                    
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
            firstnameField.placeholderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            firstnameField.borderActiveColor = #colorLiteral(red: 0.03833928332, green: 0.3575392365, blue: 0.3587242961, alpha: 1)
            firstnameField.borderInactiveColor = #colorLiteral(red: 0.2588235294, green: 0.7529411765, blue: 0.7921568627, alpha: 1)
 
            lastnameField.placeholderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            lastnameField.borderActiveColor = #colorLiteral(red: 0.03833928332, green: 0.3575392365, blue: 0.3587242961, alpha: 1)
            lastnameField.borderInactiveColor = #colorLiteral(red: 0.2588235294, green: 0.7529411765, blue: 0.7921568627, alpha: 1)

            emailField.placeholderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            emailField.borderActiveColor = #colorLiteral(red: 0.03833928332, green: 0.3575392365, blue: 0.3587242961, alpha: 1)
            emailField.borderInactiveColor = #colorLiteral(red: 0.2588235294, green: 0.7529411765, blue: 0.7921568627, alpha: 1)

            phoneField.placeholderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            phoneField.borderActiveColor = #colorLiteral(red: 0.03833928332, green: 0.3575392365, blue: 0.3587242961, alpha: 1)
            phoneField.borderInactiveColor = #colorLiteral(red: 0.2588235294, green: 0.7529411765, blue: 0.7921568627, alpha: 1)

            r_usernameField.placeholderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            r_usernameField.borderActiveColor = #colorLiteral(red: 0.03833928332, green: 0.3575392365, blue: 0.3587242961, alpha: 1)
            r_usernameField.borderInactiveColor = #colorLiteral(red: 0.2588235294, green: 0.7529411765, blue: 0.7921568627, alpha: 1)

            r_passwordField.placeholderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            r_passwordField.borderActiveColor = #colorLiteral(red: 0.03833928332, green: 0.3575392365, blue: 0.3587242961, alpha: 1)
            r_passwordField.borderInactiveColor = #colorLiteral(red: 0.2588235294, green: 0.7529411765, blue: 0.7921568627, alpha: 1)
        }
    
        func addWarningToFields() {
            resetFieldColors()
            for field in invalidRegistrationFields {
                switch field {
                case "First Name":
                    firstnameField.placeholderColor = #colorLiteral(red: 0.6275777284, green: 0, blue: 0.06438077612, alpha: 1)
                    firstnameField.borderActiveColor = #colorLiteral(red: 0.6275777284, green: 0, blue: 0.06438077612, alpha: 1)
                    firstnameField.borderInactiveColor = #colorLiteral(red: 0.6275777284, green: 0, blue: 0.06438077612, alpha: 1)
                case "Last Name":
                    lastnameField.placeholderColor = #colorLiteral(red: 0.6275777284, green: 0, blue: 0.06438077612, alpha: 1)
                    lastnameField.borderActiveColor = #colorLiteral(red: 0.6275777284, green: 0, blue: 0.06438077612, alpha: 1)
                    lastnameField.borderInactiveColor = #colorLiteral(red: 0.6275777284, green: 0, blue: 0.06438077612, alpha: 1)
                case "Email":
                    emailField.placeholderColor = #colorLiteral(red: 0.6275777284, green: 0, blue: 0.06438077612, alpha: 1)
                    emailField.borderActiveColor = #colorLiteral(red: 0.6275777284, green: 0, blue: 0.06438077612, alpha: 1)
                    emailField.borderInactiveColor = #colorLiteral(red: 0.6275777284, green: 0, blue: 0.06438077612, alpha: 1)
                case "Phone Number":
                    phoneField.placeholderColor = #colorLiteral(red: 0.6275777284, green: 0, blue: 0.06438077612, alpha: 1)
                    phoneField.borderActiveColor = #colorLiteral(red: 0.6275777284, green: 0, blue: 0.06438077612, alpha: 1)
                    phoneField.borderInactiveColor = #colorLiteral(red: 0.6275777284, green: 0, blue: 0.06438077612, alpha: 1)
                case "Username":
                    r_usernameField.placeholderColor = #colorLiteral(red: 0.6275777284, green: 0, blue: 0.06438077612, alpha: 1)
                    r_usernameField.borderActiveColor = #colorLiteral(red: 0.6275777284, green: 0, blue: 0.06438077612, alpha: 1)
                    r_usernameField.borderInactiveColor = #colorLiteral(red: 0.6275777284, green: 0, blue: 0.06438077612, alpha: 1)
                case "Password":
                    r_passwordField.placeholderColor = #colorLiteral(red: 0.6275777284, green: 0, blue: 0.06438077612, alpha: 1)
                    r_passwordField.borderActiveColor = #colorLiteral(red: 0.6275777284, green: 0, blue: 0.06438077612, alpha: 1)
                    r_passwordField.borderInactiveColor = #colorLiteral(red: 0.6275777284, green: 0, blue: 0.06438077612, alpha: 1)
                default:
                    return
            }
        }
    }
}
