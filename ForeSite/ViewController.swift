//
//  ViewController.swift
//  ForeSite
//
//  Created by Bhargava on 12/9/18.
//  Copyright © 2018 Bhargava. All rights reserved.
//
// GraphQL endpoint: https://z6iwdgs6kvaydovv2vxjndmady.appsync-api.us-west-2.amazonaws.com/graphql
// GraphQL API KEY: da2-mtmrgffztvaktohykfzsib6icy
import UIKit
import AWSAppSync
import AWSMobileClient

class ViewController: UIViewController {

    var appSyncClient: AWSAppSyncClient?
    
    var menuShowing = false
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
//    @IBOutlet weak var signInStateLabel: UILabel!
    @IBOutlet weak var sidemenuView: UIView!
    
    @IBOutlet var pageView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sidemenuView.layer.shadowOpacity = 1
        sidemenuView.layer.shadowRadius = 6
        
        AWSMobileClient.sharedInstance().initialize { (userState, error) in
            if let userState = userState {
                print("UserState: \(userState.rawValue)")
            } else if let error = error {
                print("error: \(error.localizedDescription)")
            }
        }
        
        AWSMobileClient.sharedInstance()
            .showSignIn(navigationController: self.navigationController!,
                        signInUIOptions: SignInUIOptions(
                            canCancel: false,
                            logoImage: UIImage(named: "foresite-icon-1024.png"),
                            backgroundColor: UIColor.black)) { (result, err) in
                                //handle results and errors
        }
        
        AWSMobileClient.sharedInstance().signUp(username: "your_username",
                                                password: "Abc@123!",
                                                userAttributes: ["email":"john@doe.com", "phone_number": "+1973123456"]) { (signUpResult, error) in
            if let signUpResult = signUpResult {
                switch(signUpResult.signUpConfirmationState) {
                case .confirmed:
                    print("User is signed up and confirmed.")
                case .unconfirmed:
                    print("User is not confirmed and needs verification via \(signUpResult.codeDeliveryDetails!.deliveryMedium) sent at \(signUpResult.codeDeliveryDetails!.destination!)")
                case .unknown:
                    print("Unexpected case")
                }
            } else if let error = error {
                if let error = error as? AWSMobileClientError {
                    switch(error) {
                    case .usernameExists(let message):
                        print(message)
                    default:
                        break
                    }
                }
                print("\(error.localizedDescription)")
            }
        }
        
        AWSMobileClient.sharedInstance().signIn(username: "your_username", password: "Abc@123!") { (signInResult, error) in
            if let error = error  {
                print("\(error.localizedDescription)")
            } else if let signInResult = signInResult {
                switch (signInResult.signInState) {
                case .signedIn:
                    print("User is signed in.")
                case .smsMFA:
                    print("SMS message sent to \(signInResult.codeDetails!.destination!)")
                default:
                    print("Sign In needs info which is not et supported.")
                }
            }
        }
        
        AWSMobileClient.sharedInstance().confirmSignIn(challengeResponse: "code_here") { (signInResult, error) in
            if let error = error  {
                print("\(error.localizedDescription)")
            } else if let signInResult = signInResult {
                switch (signInResult.signInState) {
                case .signedIn:
                    print("User is signed in.")
                default:
                    print("\(signInResult.signInState.rawValue)")
                }
            }
        }
        
        AWSMobileClient.sharedInstance().signOut()
    }
    
    
    @IBAction func openMenu(_ sender: Any) {
        if (menuShowing){
            leadingConstraint.constant = -310
            self.view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            UIView.animate(withDuration: 0.3,
                            animations:{
                            self.view.layoutIfNeeded()
            })
            
        }else{
            leadingConstraint.constant = 0
            self.view.backgroundColor = #colorLiteral(red: 0.5218608596, green: 0.4965139438, blue: 0.5038792822, alpha: 0.9030661387)
            UIView.animate(withDuration: 0.3,
                            animations:{
                            self.view.layoutIfNeeded()
            })
            
        }
        menuShowing = !menuShowing
    }
}

