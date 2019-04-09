//
//  ViewController.swift
//  ForeSite
//
//  Created by Bhargava on 12/9/18.
//  Copyright © 2018 Bhargava. All rights reserved.
//
// GraphQL endpoint: https://z6iwdgs6kvaydovv2vxjndmady.appsync-api.us-west-2.amazonaws.com/graphql
// cognitobd71c0bf_userpool_bd71c0bf
// https://aws-amplify.github.io/docs/ios/authentication
// GraphQL API KEY: da2-mtmrgffztvaktohykfzsib6icy
// References:
// https://peterwitham.com/swift-archives/how-to-use-a-uipickerview-as-input-for-a-uitextfield/
import UIKit
//import AWSAppSync
//import AWSMobileClient
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {

//    var appSyncClient: AWSAppSyncClient?
    
    var menuShowing = false
    var dragging = false
    
    var currentCategory = "All"
    var currentSort = "Relevant"
    var tempSort = "Relevant"
    var tempCategory = "All"
    
    let sideMenuWidth = 310
    var initialTouchPosition = CGFloat(0)
    
    let categoryOptions = [String](arrayLiteral: "All", "Entertainment", "Food", "Music", "Tech")
    let sortOptions = [String](arrayLiteral: "Relevant", "Nearest", "Cheapest", "Soonest")
    
    lazy var sampleEvents = [event]()
//    var sampleEvents = [event(title:"1st Annual iOS Machine Learning Hackathon Extravaganza", startDay: "January 31, 2019", startTime:"12:00 PM", endDay: "February 2, 2019", endTime: "11:20 PM", price:"$69.99+", location: "SCU Locatelli Student Activity Center", image: "machine-learning"), event(title:"Spring Career Fair", startDay: "February 28, 2019", startTime:"12:00 PM", endDay: "February 28, 2019", endTime: "5:00 PM", price:"FREE", location: "San Jose Marriott Hotel", image: "career-fair")]
    
    @IBOutlet var sideBarButtons: [UIButton]!
    
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    //    @IBOutlet weak var signInStateLabel: UILabel!
    @IBOutlet weak var sidemenuView: UIView!
    @IBOutlet weak var eventTableView: UITableView!
    
    
    @IBOutlet var pageView: UIView!
    
    let selectTextColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    let defaultTextColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    let categoryPicker = UIPickerView()
    let sortPicker = UIPickerView()
    
    @IBOutlet weak var eventToolbar: UIToolbar!
    
    @IBOutlet weak var CategoryField: UITextField!
    @IBOutlet weak var SortField: UITextField!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleEvents.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "EventDetailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EventViewController {
            destination.event = sampleEvents[(eventTableView.indexPathForSelectedRow?.row)!]
        }
    }
    //Generates the table cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventTableViewCell
        
        let event = sampleEvents[indexPath.row]
        print(event)
        cell.eventTitle?.text = event.title
        cell.eventStart?.text = event.startDay + " • " + event.startTime
        cell.eventEnd?.text = event.endDay + " • " + event.endTime
        cell.eventPrice?.text = event.price
        cell.eventLocation?.text = event.location
        cell.eventImage?.image = UIImage(named: event.image)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
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
        
        self.eventTableView.delegate = self
        self.eventTableView.dataSource = self
        sidemenuView.layer.shadowOpacity = 1
        sidemenuView.layer.shadowRadius = 6
        
        //SortField.layoutMargins
        self.initialize_categoryPicker(textfield: self.CategoryField, options: self.categoryPicker)
        self.initialize_categoryPicker(textfield: self.SortField, options: self.sortPicker)
        
        self.fetchEvents()

    }

    //touch gesture event listener
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(menuShowing){
            if let touch = touches.first {
                let position = touch.location(in: view)
                    initialTouchPosition = position.x
                if sidemenuView.frame.contains(position){
                    dragging = true
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = event?.allTouches?.first
        let touchPoint = touch?.location(in: view)
        if (menuShowing == true && dragging) {
            let touchX = (touchPoint?.x)!
            //print("leading: ",leadingConstraint.constant)
            if(touchX < 300 && leadingConstraint.constant <= 0){
                //print("moved: ", touchX)
                let newPos = -1*(initialTouchPosition - touchX)
                if (newPos <= 0){
                    leadingConstraint.constant = -1*(initialTouchPosition - touchX)
                    //print("position: ",leadingConstraint.constant)
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        dragging = false
        if(menuShowing){
            if(leadingConstraint.constant < -100){
                menuShowing = true //close menu
                openMenu((Any).self)
            }else{
                menuShowing = false //keep it open
                openMenu((Any).self)
            }
        }
        
        if(menuShowing){
            if let touch = touches.first {
                let position = touch.location(in: view)
                initialTouchPosition = position.x
                //print("posX: " , position.x)
                //                print(sideMenuWidth)
                if(Int(position.x) > sideMenuWidth){
                    openMenu((Any).self)
                }
                if sidemenuView.frame.contains(position){
                    dragging = true
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

            self.eventTableView.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.20,
                            animations:{
                            self.view.layoutIfNeeded()
            })
            self.eventToolbar.isUserInteractionEnabled = true
            //self.eventToolbar.isHidden = false
        }else{
            leadingConstraint.constant = 0
            //self.view.backgroundColor = #colorLiteral(red: 0.5218608596, green: 0.4965139438, blue: 0.5038792822, alpha: 0.9030661387)
            //self.eventTableView.backgroundColor = #colorLiteral(red: 0.5218608596, green: 0.4965139438, blue: 0.5038792822, alpha: 0.9030661387)
            self.eventTableView.isUserInteractionEnabled = false
            
            UIView.animate(withDuration: 0.3,
                            animations:{
                            self.view.layoutIfNeeded()
            })
            //self.eventToolbar.isHidden = true
            self.eventToolbar.isUserInteractionEnabled = false
        }
        menuShowing = !menuShowing
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
    
    @IBAction func SignOut(_ sender: Any) {
        username = "" //reset username that is logged in
        performSegue(withIdentifier: "SignOutSegue", sender: self)
    }
    
    func fetchEvents(){
        var events = [event]()
        
        AF.request("http://127.0.0.1:5000/foresite/getEventList", method: .post, encoding: JSONEncoding.default).responseJSON{ response in
            
            do{
                let json = try JSON(data: response.data!)
                //print(json)
                print(json["results"])
                if(json["response"] == "success"){
                    if let fetched_events = json["results"].array{
                        for c_event in fetched_events{
                            let current_event = event(title: c_event["title"].string!, startDay: c_event["start_date"].string!, startTime: c_event["start_time"].string!, endDay: c_event["end_date"].string!, endTime: c_event["end_time"].string!, price: c_event["subtotal_price"].rawString()!, location: c_event["street"].string!, image: "placeholder")

                            self.sampleEvents.append(current_event)
                        }
                        self.eventTableView.reloadData()
                    }
                }
            }catch{
                print("ERROR: Failed to cast request to JSON format")
            }
        }
//        var sampleEvents = [event(title:"1st Annual iOS Machine Learning Hackathon Extravaganza", startDay: "January 31, 2019", startTime:"12:00 PM", endDay: "February 2, 2019", endTime: "11:20 PM", price:"$69.99+", location: "SCU Locatelli Student Activity Center", image: "machine-learning"), event(title:"Spring Career Fair", startDay: "February 28, 2019", startTime:"12:00 PM", endDay: "February 28, 2019", endTime: "5:00 PM", price:"FREE", location: "San Jose Marriott Hotel", image: "career-fair")]
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
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelClick))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        textfield.inputView = options
        textfield.inputAccessoryView = toolBar
    }
    
}
