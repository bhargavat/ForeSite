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

//Event Details controller
class EventViewController: UIViewController {
    
    @IBOutlet weak var testHTTPLabel: UILabel!
    @IBOutlet weak var eventDescriptionTextView: UITextView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var event: event?
    var survey_questions: JSON?
    let minTitleChars:Int = 23
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let length = event?.title.count
        
        if (length! < minTitleChars){
            self.navigationItem.title = event?.title
        }else{
            self.navigationItem.title = getTruncatedTitle(str: event!.title)
        }

        let parameters: Parameters = ["event_id": event?.id as Any]

        AF.request(base_url + "/foresite/getEventDetails", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{ response in

            do{
                
                let json = try JSON(data: response.data!)
                let eventDetails = json["results"]
                
                var imageRef = "placeholder"
                var imageData: Data? = nil
                //print(c_event["thumbnail_icon"].exists())
                self.imageView.image = UIImage(named: "placeholder")
                if(eventDetails["thumbnail_icon"].string != nil){
                    imageRef = eventDetails["thumbnail_icon"].string!
                    let imageUrl = URL(string: imageRef)
                    if((imageUrl) != nil){
                        imageData = try? Data(contentsOf: imageUrl!)
                        if(imageData != nil){
                            self.imageView.image = UIImage(data: imageData!)
                        }
                    }
                }
                
                let str_location = eventDetails["street"].string! + "\n" + eventDetails["city"].string! + ", " + eventDetails["state"].string! + " " + eventDetails["zip_code"].string!
                
                let eventTimeLabelText: String = "From: " + self.reformatDate(dateString: eventDetails["start_date"].string!, fromFormat: "MM-dd-yyyy", toFormat: "MMMM dd, yyyy") + " " +  self.reformatDate(dateString: eventDetails["start_time"].string!, fromFormat: "HH:mm", toFormat: "h:mm a") + "\n" + "To: " + self.reformatDate(dateString: eventDetails["end_date"].string!, fromFormat: "MM-dd-yyyy", toFormat: "MMMM dd, yyyy") + " " + self.reformatDate(dateString: eventDetails["end_time"].string!, fromFormat: "HH:mm", toFormat: "h:mm a")
                
                self.eventTimeLabel.text = eventTimeLabelText
                self.testHTTPLabel.text = str_location
                self.eventNameLabel.text = eventDetails["title"].string!
                self.eventDescriptionTextView.text = eventDetails["description"].string!
                self.eventDescriptionTextView.isEditable = false
                
                self.survey_questions = JSON(eventDetails["survey_questions"])
            }catch{
                print("ERROR: Failed to cast to JSON format")
            }
            print("Request: \(String(describing: response.request))")
            print("Response: \(String(describing: response.response))")
            print("Error: \(String(describing: response.error))")
        }
        // Do any additional setup after loading the view.
    }
    
    func reformatDate(dateString: String, fromFormat:String, toFormat:String) -> String {
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = fromFormat
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = toFormat
        
        if let date = dateFormatterGet.date(from: dateString) {
            return dateFormatterPrint.string(from: date)
        } else {
            return dateString
        }
    }
    
    func getTruncatedTitle(str:String) -> String{
        var truncatedTitle = String(str.prefix(minTitleChars))
        if truncatedTitle.hasSuffix(" "){
            truncatedTitle = "" + truncatedTitle.dropLast()
        }
        truncatedTitle += "..."
        return truncatedTitle
    }
    
    //reference: https://stackoverflow.com/questions/29221586/swift-how-to-convert-string-to-dictionary
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "eventCheckoutSegue" {
            if let destination = segue.destination as? CheckoutController {
                destination.checkout_event = event
                destination.survey_questions = survey_questions!
                print("segue:",survey_questions!)
            }
        }
    }

}
