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

class OrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddOnUpdated {
    
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
    
    var ticketID: String = ""
    var ticketsRedeemed: Int = 0
    var ticketQuantity: Int = 0
    var redeemQtySelected: Double = 1
    var add_ons: [JSON] = []
    
    override func viewDidLoad(){
        super.viewDidLoad()
        let backButton: UIBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.back))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.title = "Order Details"
        self.AddOnRedeemTableView.delegate = self
        self.AddOnRedeemTableView.dataSource = self
        print("ID:", ticketID)

        self.getEventDetails()
//        self.AddOnRedeemTableView.register(AddOnTableViewCell.self, forCellReuseIdentifier: "AddOnRedeemCell")
    }
    func quantityUpdated(label: String, value: Int) {
        for idx in 0..<add_ons.count{
            var c_addon: JSON = add_ons[idx]
            if(c_addon["name"].string! == label){
                c_addon["quantity"] = JSON(value)
                self.add_ons[idx] = c_addon
                return
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count: ",add_ons.count)
        return add_ons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddOnRedeemCell", for: indexPath) as! AddOnRedeemTableViewCell
        let c_addon:JSON = add_ons[indexPath.row]
        print("caddon-name:",c_addon["name"].string!)
        cell.addonLabel?.text = c_addon["name"].string!
        cell.quantityLabel?.text = String(c_addon["quantity"].int!) + "/" + String(c_addon["quantity"].int!)
        cell.quantity = c_addon["quantity"].int!
        cell.max_quantity = self.add_ons[indexPath.row]["quantity"].int!
        cell.quantityStepper.value = Double(c_addon["quantity"].int!)
        return cell
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
//    func quantityUpdated(label: String, value: Int) {
//        for idx in 0..<add_ons.count{
//            var c_addon: Dictionary<String, Any> = add_ons[idx] as! Dictionary<String, Any>
//            if(String(describing: c_addon["name"]!) == label){
//                c_addon["quantity"] = value
//                self.add_ons[idx] = c_addon
//                return
//            }
//        }
//    }
    
    @IBAction func RedeemStepperClicked(_ sender: UIStepper) {
        if(Int(sender.value) <= (self.ticketQuantity - self.ticketsRedeemed) && Int(sender.value) > 0){
            redeemQtySelected = sender.value
            RedeemLabel.text = "Redeem \(Int(sender.value)) of \(self.ticketQuantity - self.ticketsRedeemed)"
        }
        quantityStepper.value = self.redeemQtySelected
    }
    
    
    @IBAction func openQRPopup(_ sender: Any) {
        let vc = QRPopupViewController()
        //print("TICKET_IMG:", ticketID.generateQRCode())
        vc.QRData = ticketID + ":" + String(Int(redeemQtySelected))
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }
    
    
    func getEventDetails(){
        let parameters = ["ticket_id": ticketID]
        AF.request(base_url + "/foresite/getTicketDetails", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{ response in
            //print("resp",response.data!)
            do{
                let json = try JSON(data: response.data!)
                if(json["response"] == "success"){
                    
                    let eventDetails:JSON = json["results"]
                    print(eventDetails)
                    self.eventTitleLabel.text = eventDetails["title"].string!
                    self.eventTicketQtyLabel.text = "Quantity: " + String(eventDetails["amount_bought"].int!)
                    self.eventLocationLabel.text = eventDetails["street"].string! + "\n" + eventDetails["city"].string! + ", " + eventDetails["state"].string! + " " + eventDetails["zip_code"].string!
                    self.eventStartLabel.text = "From: " + eventDetails["start_date"].string!.reformatDate( fromFormat: "MM-dd-yyyy", toFormat: "MMMM dd, yyyy") + " " + eventDetails["start_time"].string!.reformatDate(fromFormat: "HH:mm", toFormat: "h:mm a")
                    self.eventEndLabel.text = "To: " + eventDetails["end_date"].string!.reformatDate( fromFormat: "MM-dd-yyyy", toFormat: "MMMM dd, yyyy") + " " + eventDetails["end_time"].string!.reformatDate(fromFormat: "HH:mm", toFormat: "h:mm a")
                    self.RedeemLabel.text = "Redeem 1 of " + String(eventDetails["amount_bought"].int!)
                    self.ticketsRedeemed = eventDetails["is_ticket_redeemed"].int!
                    self.ticketQuantity = eventDetails["amount_bought"].int!
                    print("shiet:",eventDetails["add_ons"].arrayValue)
                    self.add_ons = eventDetails["add_ons"].arrayValue
                    ticket_qty = eventDetails["amount_bought"].int! - eventDetails["is_ticket_redeemed"].int!
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
