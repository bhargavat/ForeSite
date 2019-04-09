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

class AuthController: UIViewController{
    @IBOutlet weak var signInBtn: UIButton!
    
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
                        print("SUCCESS")
                        username = usernameInput!

                        self.performSegue(withIdentifier: "EventListSegue", sender: self)
                    }else{
                        let alertController = UIAlertController(title: "Login Failed", message:
                            "Incorrect login credentials", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default))
                        
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
            let alertController = UIAlertController(title: "Registration Failed", message:
                "Invalid registration data", preferredStyle: .alert)
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
        if(firstnameField.text! == "" || lastnameField.text! == ""){
            return false
        }
        if(emailField.text!.isEmail == false){
            return false
        }
        if(phoneField.text!.isPhoneNumber == false){
            return false
        }
        if(r_usernameField.text!.count < 2){
            return false
        }
        if(r_passwordField.text!.count < 2){
            return false
        }
        return true
    }
}
