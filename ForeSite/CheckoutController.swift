//
//  CheckoutController.swift
//  ForeSite
//
//  Created by Bhargava on 4/17/19.
//  Copyright © 2019 Bhargava. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

protocol AddOnUpdated: class {
    func quantityUpdated(label: String, value: Int)
}

class CheckoutController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddOnUpdated{

    
    
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var AddOnTableView: UITableView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var subtotalLabel: UILabel!
    
    var checkout_event: event?
    var survey_questions: JSON!
    var add_ons: Array<Any> = []
    var event_subtotal: Double = 0.0 //price per base ticket
    var addOnPrice: Double = 0.00
    var perTicketTotal: Double = 0.0
    var quantities:Array<Int> = []
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.AddOnTableView.delegate = self
        self.AddOnTableView.dataSource = self
        self.add_ons = (self.checkout_event?.add_ons)!

        for idx in 0..<add_ons.count {
            var c_addon: Dictionary<String, Any> = add_ons[idx] as! Dictionary<String, Any>
            c_addon["quantity"] = 0
            self.add_ons[idx] = c_addon
            
        }
        ticket_qty = 1
        quantities = [Int](repeating: 0, count: self.add_ons.count)
        self.AddOnTableView.refreshControl = nil
        navigationItem.title = "Checkout"
        let event_price = Double(checkout_event?.price ?? "0.0")
        self.event_subtotal = Double((event_price!/100.0).dollarRound())!
        self.perTicketTotal = Double((event_price!/100.0).dollarRound())!
        totalPriceLabel.text = (event_price!/100.0).dollarRound()
        subtotalLabel.text = (event_price!/100.0).dollarRound()
    }
    
    //delegate function called by AddOnTableViewCell to update add_on qty
    func quantityUpdated(label: String, value: Int) {
        for idx in 0..<add_ons.count{
            var c_addon: Dictionary<String, Any> = add_ons[idx] as! Dictionary<String, Any>
            if(String(describing: c_addon["name"]!) == label){
                c_addon["quantity"] = value
                self.add_ons[idx] = c_addon
                calculateTotalPrice()
                return
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.add_ons.count
    }
    
    //generate each cell in table view. called once per cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            //print("RELOADING cell #",indexPath.row)
            let add_on = JSON(self.add_ons[indexPath.row])
            //print("cell:",add_ons)
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddOnCell", for: indexPath) as! AddOnTableViewCell
            cell.delegate = self
            let price = Double(add_on["price"].int!)/100.0
        
            cell.addonLabel?.text = add_on["name"].string! + " (+$\(price.roundTo(places: 2))" + ")"
            cell.quantityLabel.text = String(describing: add_on["quantity"].int!)
            cell.quantityStepper.value = Double(add_on["quantity"].int!)
            cell.quantity = add_on["quantity"].int!
        
            return cell
    }
    
    func updateTotal(quantities: [Int]) -> Double{
        var result:Double = 0.0
        for i in 0..<quantities.count{
            let curr_addon = JSON(self.add_ons[i])
            let price = Double(curr_addon["price"].int!)/100.0
            result += Double(quantities[i]) * price
        }
        return result.dollarRoundDouble()
    }
    //reference: https://stackoverflow.com/questions/30059704/uitableviewcell-checkmark-to-be-toggled-on-and-off-when-tapped
    
    //update the ticket quantity value
    @IBAction func ticketQtyUpdate(_ sender: UIButton) {
        print("QUANTITY UPDATE")
        let quantity:String = quantityLabel.text!
        let btnText: String = sender.titleLabel!.text!
        //print(perTicketTotal)
        if ((btnText == "–" && Int(quantity)! > 1) || (btnText == "+" && Int(quantity)! < 9)) {
            var multiplier: Int = 1
            if(sender.titleLabel!.text == "–"){
                multiplier = -1
            }
            quantityLabel.text = String(Int(quantity)! + 1*multiplier)
            ticket_qty = Int(quantity)! + 1*multiplier
            let priceString = (perTicketTotal * Double(quantityLabel.text!)! + addOnPrice).dollarRound()
            if(quantityLabel.text != "0.0"){
                totalPriceLabel.text = priceString
            }
            
            subtotalLabel.text = ((Double(quantity)! + Double(multiplier)) * event_subtotal).dollarRound()
            //calculateTotalPrice()
            if(multiplier == -1){
                correctAddOnQty()
                calculateTotalPrice()
            }
            //AddOnTableView.reloadData()
        }
        
    }
    
    func calculateTotalPrice(){
        self.addOnPrice = 0
        print(add_ons)
        for idx in 0..<add_ons.count {
            var c_addon: Dictionary<String, Any> = add_ons[idx] as! Dictionary<String, Any>
            let quantity: Double = Double(c_addon["quantity"] as! Int)
            print("quantity ",quantity)
            self.addOnPrice += (((c_addon["price"] as! Double)/100.0).dollarRoundDouble()) * quantity
        }
        print("price:",addOnPrice)
        print(String((self.addOnPrice + self.event_subtotal).dollarRound()))
        self.totalPriceLabel.text = String((self.addOnPrice + Double(self.quantityLabel.text!)! * self.event_subtotal).dollarRound())
        //self.subtotalLabel.text = String(self.addOnPrice)
    }
    
    //synchronizes add-on quantities when ticket quantity decremented
    func correctAddOnQty(){
        for idx in 0..<add_ons.count {
            var c_addon: Dictionary<String, Any> = add_ons[idx] as! Dictionary<String, Any>
            if(ticket_qty < (c_addon["quantity"] as! Int)){
                c_addon["quantity"] = ticket_qty
                add_ons[idx] = c_addon
            }
        }
        AddOnTableView.reloadData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "eventSurveySegue" {
            if let destination = segue.destination as? SurveyController {
                destination.checkout_event = checkout_event!
                destination.survey_questions = survey_questions!
                destination.add_ons = self.add_ons
                print("segue1:",survey_questions!)
            }
        }
    }
    
}
