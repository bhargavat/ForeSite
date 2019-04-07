//
//  EventViewController.swift
//  ForeSite
//
//  Created by Bhargava on 2/6/19.
//  Copyright © 2019 Bhargava. All rights reserved.
//  References:
//  https://www.youtube.com/watch?v=v0Hx7q26Hoo (segue from tableview cell)
//  https://www.youtube.com/watch?v=5hcHbhIWIeI&t=122s
//
import UIKit
import Alamofire
import SwiftyJSON

class EventViewController: UIViewController {
    
    @IBOutlet weak var testHTTPLabel: UILabel!
    
    @IBOutlet weak var eventDescriptionTextView: UITextView!
    @IBOutlet weak var eventNameLabel: UILabel!
    
    
    private let networkingClient = NetworkingClient()
    var event: event?
    let minTitleChars:Int = 23
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let length = event?.title.count
        
        if (length! < minTitleChars){
            self.navigationItem.title = event?.title
        }else{
            self.navigationItem.title = getTruncatedTitle(str: event!.title)
        }
//
        let parameters: Parameters = ["event_id": "E001"]

        AF.request("http://127.0.0.1:5000/foresite/getEventDetails", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{ response in

            do{

                let json = try JSON(data: response.data!)
                print(json)
                let eventDetails = json[0]
                let str_location = eventDetails["street"].string! + "\n" + eventDetails["city"].string! + ", " + eventDetails["state"].string! + " " + eventDetails["zip_code"].string!
                self.testHTTPLabel.text = str_location
                self.eventNameLabel.text = eventDetails["title"].string!
                self.eventDescriptionTextView.text = eventDetails["description"].string!
                self.eventDescriptionTextView.isEditable = false
                print("json:",json[0]["city"].string!)
            }catch{
                print("ERROR: Failed to cast to JSON format")
            }
            print("Request: \(String(describing: response.request))")
            print("Response: \(String(describing: response.response))")
            print("Error: \(String(describing: response.error))")
        }
        // Do any additional setup after loading the view.
    }
    
    func getTruncatedTitle(str:String) -> String{
        var truncatedTitle = String(str.prefix(minTitleChars))
        if truncatedTitle.hasSuffix(" "){
            truncatedTitle = "" + truncatedTitle.dropLast()
        }
        truncatedTitle += "..."
        return truncatedTitle
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
