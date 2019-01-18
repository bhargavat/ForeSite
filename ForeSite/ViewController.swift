//
//  ViewController.swift
//  ForeSite
//
//  Created by Bhargava on 12/9/18.
//  Copyright © 2018 Bhargava. All rights reserved.
//
// GraphQL endpoint: https://z6iwdgs6kvaydovv2vxjndmady.appsync-api.us-west-2.amazonaws.com/graphql
//cognitobd71c0bf_userpool_bd71c0bf
// GraphQL API KEY: da2-mtmrgffztvaktohykfzsib6icy
// References:
// https://peterwitham.com/swift-archives/how-to-use-a-uipickerview-as-input-for-a-uitextfield/
import UIKit
import AWSAppSync
import AWSMobileClient

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var appSyncClient: AWSAppSyncClient?
    
    var menuShowing = false
    
    var currentCategory = "All"
    var currentSort = "Relevant"
    var tempSort = "Relevant"
    var tempCategory = "All"
    
    let sideMenuWidth = 310
    
    let categoryOptions = [String](arrayLiteral: "All", "Entertainment", "Food", "Music", "Tech")
    let sortOptions = [String](arrayLiteral: "Relevant", "Nearest", "Cheapest", "Soonest")
    
    @IBOutlet var sideBarButtons: [UIButton]!
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    //    @IBOutlet weak var signInStateLabel: UILabel!
    @IBOutlet weak var sidemenuView: UIView!
    
    @IBOutlet var pageView: UIView!
    
    let selectTextColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    let defaultTextColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    let categoryPicker = UIPickerView()
    let sortPicker = UIPickerView()
    
    @IBOutlet weak var eventToolbar: UIToolbar!
    
    @IBOutlet weak var CategoryField: UITextField!
    @IBOutlet weak var SortField: UITextField!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //Sets the quantity of items for UIPickerView
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView == categoryPicker){
            return categoryOptions.count
        }else if(pickerView == sortPicker){
            return sortOptions.count
        }else{
            return 0
        }
    }
    
    //Sets the UIPickerView items
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == categoryPicker){
            return categoryOptions[row]
        }else if(pickerView == sortPicker){
            return sortOptions[row]
        }else{
            return nil
        }
    }
    
    //Sets the textField's value based on selection in the UIPickerView
    func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView == categoryPicker){
            CategoryField.text = "Category:  " + categoryOptions[row]
            CategoryField.textColor = selectTextColor
            tempCategory = categoryOptions[row]
        }else if(pickerView == sortPicker){
            SortField.text = "Sort By:  " + sortOptions[row]
            SortField.textColor = selectTextColor
            tempSort = sortOptions[row]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sidemenuView.layer.shadowOpacity = 1
        sidemenuView.layer.shadowRadius = 6
        
        //SortField.layoutMargins
        self.initialize_categoryPicker(textfield: self.CategoryField, options: self.categoryPicker)
        self.initialize_categoryPicker(textfield: self.SortField, options: self.sortPicker)
        
        AWSMobileClient.sharedInstance().initialize { (userState, error) in
            if let userState = userState {
                print("UserState: \(userState.rawValue)")
            } else if let error = error {
                print("Error1: \(error.localizedDescription)")
            }
        }
        
        //Customize login icon
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
                print("HOO")
                if let error = error as? AWSMobileClientError {
                    switch(error) {
                    case .usernameExists(let message):
                        print("shoot")
                        print("shoot: ", message)
                    default:
                        break
                    }
                }
//                print("OOPS")
//                let alert = UIAlertController(title: "Login Failed", message: "Invalid login credentials. Try again.", preferredStyle: .alert)
//
//                alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: nil))
//
//                self.present(alert, animated: true)
                print("\(error.localizedDescription)")
            }
        }
        
        AWSMobileClient.sharedInstance().signIn(username: "your_username", password: "Abc@123!") { (signInResult, error) in
            if let error = error  {
                print("\(error.localizedDescription)")
                print("crap")
//                let alert = UIAlertController(title: "Login Failed", message: "Invalid login credentials. Try again.", preferredStyle: .alert)
//
//                alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: nil))
//
//                self.present(alert, animated: true)
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
                    print("Login failed")
                }
            }
        }
        
        AWSMobileClient.sharedInstance().signOut()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(menuShowing){
            if let touch = touches.first {
                let position = touch.location(in: view)
                print("posX: " , position.x)
                print(sideMenuWidth)
                if(Int(position.x) > sideMenuWidth){
                    openMenu((Any).self)
                }
            }
        }
    }
    
    @IBAction func openMenu(_ sender: Any) {
        if (categoryPicker.isHidden == false || sortPicker.isHidden == false){
            cancelClick()
        }
        if (menuShowing){
            leadingConstraint.constant = CGFloat(sideMenuWidth * -1)
            self.view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            UIView.animate(withDuration: 0.3,
                            animations:{
                            self.view.layoutIfNeeded()
            })
            self.eventToolbar.isHidden = false
        }else{
            leadingConstraint.constant = 0
            self.view.backgroundColor = #colorLiteral(red: 0.5218608596, green: 0.4965139438, blue: 0.5038792822, alpha: 0.9030661387)
            UIView.animate(withDuration: 0.3,
                            animations:{
                            self.view.layoutIfNeeded()
            })
            self.eventToolbar.isHidden = true
        }
        menuShowing = !menuShowing
    }
    
    
    @IBAction func swipeSideMenuDismiss(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizer.Direction.left:
            if(menuShowing == true){
                openMenu(sender)
            }
        default:
            break
        }
    }
    

    @IBAction func flashButtonTapped(_ sender: UIButton) {
        sender.flash()
        sender.isHighlighted = true
    }

    @IBAction func navigateToPage(_ sender: UIButton) {
        
        let button_label = sender.titleLabel!.text!
        switch button_label {
        case "Events":
            menuShowing = true
            openMenu(sender)
        default:
            break
        }
    }
    
    /**
     Change text color and text based on Done or Cancel clicks
     */
    @objc func doneClick() {
        CategoryField.resignFirstResponder()
        SortField.resignFirstResponder()
        if(CategoryField.textColor == selectTextColor){
            currentCategory = tempCategory
            CategoryField.text = "Category:  " + currentCategory
            CategoryField.textColor = defaultTextColor
            SortField.isEnabled = true
        }else if(SortField.textColor == selectTextColor){
            SortField.textColor = defaultTextColor
            currentSort = tempSort
            SortField.text = "Sort By:  " + currentSort
            CategoryField.isEnabled = true
        }
    }
    @objc func cancelClick() {
        CategoryField.resignFirstResponder()
        SortField.resignFirstResponder()
        if(CategoryField.textColor == selectTextColor){
            CategoryField.textColor = defaultTextColor
            CategoryField.text = "Category:  " + currentCategory
            let orig_Index: Int = categoryOptions.firstIndex(of: currentCategory)!
            categoryPicker.selectRow(orig_Index, inComponent: 0, animated: false)
            SortField.isEnabled = true

        }else if(SortField.textColor == selectTextColor){
            SortField.textColor = defaultTextColor
            SortField.text = "Sort By:  " + currentSort
            let orig_Index: Int = sortOptions.firstIndex(of: currentSort)!
            sortPicker.selectRow(orig_Index, inComponent: 0, animated: false)
            CategoryField.isEnabled = true
            //sortPicker.selectedRow(inComponent: orig_Index)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textField != self.CategoryField;
    }
    
    @IBAction func selectorFieldSelected(_ sender: UITextField) {
        sender.textColor = selectTextColor
        if(sender == CategoryField){
            SortField.isEnabled = false
        }else if(sender == SortField){
            CategoryField.isEnabled = false
        }
    }
    
    func initialize_categoryPicker(textfield: UITextField, options: UIPickerView){
        textfield.tintColor = .clear
        
        options.delegate = self
        options.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done",style: .plain, target: self, action: #selector(self.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelClick))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        textfield.inputView = options
        textfield.inputAccessoryView = toolBar
    }
}

