//
//  OrderViewController.swift
//  ForeSite
//
//  Created by Bhargava on 5/21/19.
//  Copyright © 2019 Bhargava. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

protocol updateTicketQuantity: class{
    func updateTicketQuantity()
}
class OrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddOnUpdated, updateTicketQuantity {
    
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var eventStartLabel: UILabel!
    @IBOutlet weak var eventEndLabel: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventTicketQtyLabel: UILabel!
    @IBOutlet weak var quantitySelectionLabel: UILabel!
    @IBOutlet weak var quantityStepper: UIStepper!
    @IBOutlet weak var AddOnRedeemTableView: UITableView!
    @IBOutlet weak var RedeemLabel: UILabel!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var addOnRedeemButton: RoundButton!
    
    var ticketID: String = ""
    var ticketsRedeemed: Int = 0 //
    var ticketQuantity: Int = 0
    var redeemQtySelected: Double = 1
    var add_ons: [JSON] = []
    var addon_maxQtys: [Int] = []
    override func viewDidLoad(){
        super.viewDidLoad()
        let backButton: UIBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.back))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.title = "Order Details"
        self.AddOnRedeemTableView.delegate = self
        self.AddOnRedeemTableView.dataSource = self
        
        self.getEventDetails()
    }
    
    //delegate function
    func updateTicketQuantity() {
        if Connectivity.isConnectedToInternet {
            let parameters: Parameters = ["ticket_id":ticketID]
            AF.request(base_url + "/foresite/getTicketDetails", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{ response in
            
                do{
                    let json = try JSON(data: response.data!)
                    if(json["response"] == "success"){
                        let eventDetails:JSON = json["results"]
                        self.ticketsRedeemed = eventDetails["tickets_redeemed"].int!
                        self.ticketQuantity = eventDetails["amount_bought"].int!
                        
                        if((self.ticketQuantity - self.ticketsRedeemed) < Int(self.redeemQtySelected)){
                            self.redeemQtySelected = 1.0
                        }
                        if(self.ticketQuantity - self.ticketsRedeemed < 1){
                            self.scanButton.isEnabled = false
                            self.redeemQtySelected = 0.0
                        }
                        self.RedeemLabel.text = "Redeem \(String(Int(self.redeemQtySelected))) of " + String(eventDetails["amount_bought"].int!-eventDetails["tickets_redeemed"].int!)
                        self.eventTicketQtyLabel.text = "Quantity: " + String(eventDetails["amount_bought"].int!) + " (\(String(eventDetails["amount_bought"].int! - eventDetails["tickets_redeemed"].int!)) left)"
                    }
                }catch{
                    print("ERROR: Failed to cast to JSON format")
                }
            }
        }
    }
    
    func quantityUpdated(label: String, value: Int) {
        for idx in 0..<add_ons.count{
            var c_addon: JSON = add_ons[idx]
            if(c_addon["name"].string! == label){
                c_addon["quantity"] = JSON(value)
                self.add_ons[idx] = c_addon
                self.disableAddOnRedemptionButton()
                return
            }
        }
    }
    
    //disable add-on redemption button if quantity used up
    func disableAddOnRedemptionButton(){
        for add_on in add_ons{
            if(add_on["quantity"].int! > 0){
                addOnRedeemButton.isEnabled = true
                addOnRedeemButton.backgroundColor = #colorLiteral(red: 0.2588235294, green: 0.7529411765, blue: 0.7921568627, alpha: 1)
                addOnRedeemButton.alpha = CGFloat(1.0)
                return
            }
        }
        addOnRedeemButton.isEnabled = false
        addOnRedeemButton.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        addOnRedeemButton.alpha = CGFloat(0.4)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "My Add-ons"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("count: ",add_ons.count)
        return add_ons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddOnRedeemCell", for: indexPath) as! AddOnRedeemTableViewCell
        cell.delegate = self
        let c_addon:JSON = add_ons[indexPath.row]
        print("caddon-name:",c_addon["name"].string!)
        cell.addonLabel?.text = c_addon["name"].string!
        cell.quantityLabel?.text = String(c_addon["quantity"].int!) + "/" + String(addon_maxQtys[indexPath.row])
        cell.quantity = c_addon["quantity"].int!
        cell.max_quantity = addon_maxQtys[indexPath.row]
        cell.quantityStepper.value = Double(c_addon["quantity"].int!)
        return cell
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func RedeemStepperClicked(_ sender: UIStepper) {
        if(Int(sender.value) <= (self.ticketQuantity - self.ticketsRedeemed) && Int(sender.value) > 0){
            redeemQtySelected = sender.value
            RedeemLabel.text = "Redeem \(Int(sender.value)) of \(self.ticketQuantity - self.ticketsRedeemed)"
        }
        quantityStepper.value = self.redeemQtySelected
    }
    
    
    @IBAction func openQRPopup(_ sender: Any) {
        let vc = QRPopupViewController()
        vc.delegate = self
        vc.QRData = ticketID + ":" + String(Int(redeemQtySelected))
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func redeemAddOnsClicked(_ sender: Any) {
        let alertController = UIAlertController(title: "Confirm", message:
            "You are about to redeem the following:\n" + self.getRedeemingAddOnsString(), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default){
            UIAlertAction in
            self.redeemAddOns()
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getRedeemingAddOnsString() -> String{
        var result: String = ""
        for add_on in self.add_ons{
            if(add_on["quantity"].int! > 0){
                let addon_string = add_on["name"].string! + " (x" + String(add_on["quantity"].int!) + ")\n"
                result += addon_string
            }
        }
        return result
    }
    func redeemAddOns(){
        if Connectivity.isConnectedToInternet {
            let parameters: Parameters = ["ticket_id":ticketID, "add_ons": JSON(add_ons).rawValue]
            AF.request(base_url + "/foresite/redeemAddOns", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{ response in
                
                do{
                    let json = try JSON(data: response.data!)
                    if(json["response"] == "success"){
                        let alert = UIAlertController(title: "Success", message: "Add-ons redeemed successfully", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true, completion: {
                            self.getEventDetails()
                        self.disableAddOnRedemptionButton()
                        })
                    }
                }catch{
                    print("ERROR: Failed to cast to JSON format")
                }
            }
        }
    }
    
    func getEventDetails(){
        if Connectivity.isConnectedToInternet {
            let parameters = ["ticket_id": ticketID]
            AF.request(base_url + "/foresite/getTicketDetails", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{ response in
                do{
                    let json = try JSON(data: response.data!)
                    if(json["response"] == "success"){
                        
                        let eventDetails:JSON = json["results"]
                        
                        self.eventTitleLabel.text = eventDetails["title"].string!
                        self.eventTicketQtyLabel.text = "Quantity: " + String(eventDetails["amount_bought"].int!) + " (\(String(eventDetails["amount_bought"].int! - eventDetails["tickets_redeemed"].int!)) left)"
                        self.eventLocationLabel.text = eventDetails["street"].string! + "\n" + eventDetails["city"].string! + ", " + eventDetails["state"].string! + " " + eventDetails["zip_code"].string!
                        self.eventStartLabel.text = "From: " + eventDetails["start_date"].string!.reformatDate( fromFormat: "MM-dd-yyyy", toFormat: "MMMM dd, yyyy") + " " + eventDetails["start_time"].string!.reformatDate(fromFormat: "HH:mm", toFormat: "h:mm a")
                        self.eventEndLabel.text = "To: " + eventDetails["end_date"].string!.reformatDate( fromFormat: "MM-dd-yyyy", toFormat: "MMMM dd, yyyy") + " " + eventDetails["end_time"].string!.reformatDate(fromFormat: "HH:mm", toFormat: "h:mm a")
                        self.RedeemLabel.text = "Redeem 1 of " + String(eventDetails["amount_bought"].int!-eventDetails["tickets_redeemed"].int!)
                        self.ticketsRedeemed = eventDetails["tickets_redeemed"].int!
                        self.ticketQuantity = eventDetails["amount_bought"].int!
                        self.add_ons = eventDetails["add_ons"].arrayValue
                        self.disableAddOnRedemptionButton()

                        if(self.addon_maxQtys.count > 0){
                            self.addon_maxQtys = [] //reset value to override it
                        }
                        for add_on in self.add_ons { //set max quantities available
                            self.addon_maxQtys.append(add_on["quantity"].int!)
                        }
                        self.ticketQuantity = eventDetails["amount_bought"].int! - eventDetails["tickets_redeemed"].int!
                        if(self.ticketQuantity < 1){
                            self.scanButton.isEnabled = false
                        }
                        var imageRef = "placeholder"
                        var imageData: Data? = nil

                        if(eventDetails["thumbnail_icon"].string != nil){
                            imageRef = eventDetails["thumbnail_icon"].string!
                            let imageUrl = URL(string: imageRef)
                            if((imageUrl) != nil){
                                imageData = try? Data(contentsOf: imageUrl!)
                            }
                        }
                        
                        var image: UIImage = UIImage(named: "placeholder")!
                        
                        if(imageRef != "placeholder" && imageData != nil){
                            image = UIImage(data: imageData!)!
                        }
                        self.eventImage.image = image
                        
                        self.AddOnRedeemTableView.reloadData()
                    }
                }catch{
                    print("ERROR: Failed to cast to JSON format")
                }
            }
        }
    }
    
}
