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

class OrderViewController: UIViewController {
    
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var eventStartLabel: UILabel!
    @IBOutlet weak var eventEndLabel: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventTicketQtyLabel: UILabel!
    @IBOutlet weak var quantitySelectionLabel: UILabel!
    @IBOutlet weak var quantityStepper: UIStepper!
    @IBOutlet weak var AddOnRedeemTableView: UITableView!
    
    var ticketID: String = ""
    //var eventDetails: JSON = []
    override func viewDidLoad(){
        super.viewDidLoad()
        let backButton: UIBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.back))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.title = "Order Details"
        
        print("ID:",ticketID)
        getEventDetails()
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func openQRPopup(_ sender: Any) {
        let vc = QRPopupViewController()
        //print("TICKET_IMG:", ticketID.generateQRCode())
        vc.QRData = ticketID
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
                    
                    self.eventTitleLabel.text = eventDetails["title"].string!
                    self.eventTicketQtyLabel.text = "Quantity: " + String(eventDetails["amount_bought"].int!)
                    self.eventLocationLabel.text = eventDetails["street"].string! + "\n" + eventDetails["city"].string! + ", " + eventDetails["state"].string! + " " + eventDetails["zip_code"].string!
                    self.eventStartLabel.text = "From: " + eventDetails["start_date"].string!.reformatDate( fromFormat: "MM-dd-yyyy", toFormat: "MMMM dd, yyyy") + " " + eventDetails["start_time"].string!.reformatDate(fromFormat: "HH:mm", toFormat: "h:mm a")
                    self.eventEndLabel.text = "To: " + eventDetails["end_date"].string!.reformatDate( fromFormat: "MM-dd-yyyy", toFormat: "MMMM dd, yyyy") + " " + eventDetails["end_time"].string!.reformatDate(fromFormat: "HH:mm", toFormat: "h:mm a")
                    
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
                    
                    
                }
            }catch{
                print("ERROR: Failed to cast to JSON format")
            }
        }
    }
    
}
