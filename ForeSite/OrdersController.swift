//
//  OrdersController.swift
//  ForeSite
//
//  Created by Bhargava on 5/18/19.
//  Copyright © 2019 Bhargava. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class OrdersController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    
    var user_tickets:[JSON] = []
    var tickets_info:[JSON] = []
    
    var selectedTicketID: String = ""
    @IBOutlet weak var ordersTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "My Orders"
        self.view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        ordersTableView.dataSource = self
        ordersTableView.delegate = self
        
        getUserTicketIds()
        print("ids: ", user_tickets)
        //ordersTableView.reloadData()
        
    }
    func addTicketDetails(data: JSON){
        self.tickets_info.append(data)
    }
    
    //when cell is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedTicketID = user_tickets[indexPath.row]["ticket_id"].string!
        print("selectID:",self.selectedTicketID)
        performSegue(withIdentifier: "ViewOrderSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("tickets: ", user_tickets.count)
        return user_tickets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as! OrderTableViewCell
        let eventDetails = user_tickets[indexPath.row]
        print(eventDetails)
        cell.quantityLabel.text = "Qty: " + String(eventDetails["amount_bought"].int!)
        cell.eventTitleLabel.text = eventDetails["title"].string!
        cell.eventStartLabel.text = eventDetails["start_date"].string!.reformatDate(fromFormat: "MM-dd-yyyy", toFormat: "MMMM dd, yyyy") + " • " + eventDetails["start_time"].string!.reformatDate(fromFormat: "HH:mm", toFormat: "h:mm a")
        cell.eventEndLabel.text = eventDetails["end_date"].string!.reformatDate(fromFormat: "MM-dd-yyyy", toFormat: "MMMM dd, yyyy") + " • " + eventDetails["end_time"].string!.reformatDate(fromFormat: "HH:mm", toFormat: "h:mm a")
        cell.eventPurchaseDate.text = "Purchased on "+eventDetails["creation_date"].string!.reformatDate(fromFormat: "E, d MMM yyyy HH:mm:ss Z", toFormat: "MMM d YYYY, h:mm a")
        
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
        cell.eventImage.image = image
        //cell.eventImage.image = eventDetails["ticket_id"].string!.generateQRCode()
        //cell.QRImage.image = generateQRCode(from: eventDetails["ticket_id"].string!)
        return cell
    }
//    func loadTicketDetails(){
//        getUserTicketIds()
//        print("after:",user_tickets)
//        for id in user_tickets{
//            self.tickets_info.append(getTicketDetails(ticket_id: id))
//        }
//    }
    
    
    func getTicketDetails(ticket_id: [String]){
        
        //print("PARAMS:",parameters)
        var details: JSON = []
        for i in 0..<user_tickets.count{
            let runLoop = CFRunLoopGetCurrent()
            let parameters = ["ticket_id":ticket_id[i]]
            AF.request(base_url + "/foresite/getTicketDetails", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{ response in
                    print("resp",response.data!)
                do{
                    let json = try JSON(data: response.data!)
                    print("DEETS:",json)
                    if(json["response"] == "success"){
                        details = json["results"]
                        print("DETAILS:",details)
                        self.tickets_info.append(details)
                    }
                    CFRunLoopStop(runLoop)
                }catch{
                    print("ERROR: Failed to cast to JSON format")
                }
            }
        }
        CFRunLoopRun()
    }
    
    func getUserTicketIds(){
        let parameters = ["user_name":username]
        AF.request(base_url + "/foresite/getUserTickets", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{ response in
            
            do{
                let json = try JSON(data: response.data!)
                print(json)
                if(json["response"] == "success"){
                    //print("HERE")
                    self.user_tickets = json["results"].arrayValue
                    self.ordersTableView.reloadData()
                }
            }catch{
                print("ERROR: Failed to cast to JSON format")
            }
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //print("identifier:",segue.identifier!)
        //print("destination:",segue.destination)
        if let destination = segue.destination as? UINavigationController,
            let orderViewController = destination.viewControllers.first as? OrderViewController {
                orderViewController.ticketID = self.selectedTicketID
            }
    }
}
