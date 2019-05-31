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
        
    }
    func addTicketDetails(data: JSON){
        self.tickets_info.append(data)
    }
    
    //when cell is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedTicketID = user_tickets[indexPath.row]["ticket_id"].string!
        performSegue(withIdentifier: "ViewOrderSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user_tickets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as! OrderTableViewCell
        let eventDetails = user_tickets[indexPath.row]
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

        return cell
    }
    
    func getTicketDetails(ticket_id: [String]){
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
                    self.user_tickets.sort(by: {(a,b) -> Bool in
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"

                        guard let date_a = dateFormatter.date(from:a["creation_date"].string!) else{
                            fatalError()
                        }
                        guard let date_b = dateFormatter.date(from:b["creation_date"].string!) else{
                            fatalError()
                        }
                        return date_a > date_b
                    })
                    self.ordersTableView.reloadData()
                }
            }catch{
                print("ERROR: Failed to cast to JSON format")
            }
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UINavigationController,
            let orderViewController = destination.viewControllers.first as? OrderViewController {
                orderViewController.ticketID = self.selectedTicketID
            }
    }
}
