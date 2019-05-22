//
//  PaymentController.swift
//  ForeSite
//
//  Created by Bhargava on 5/16/19.
//  Copyright © 2019 Bhargava. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire

class PaymentController: UIViewController{
    
    var add_ons: Array<Any> = []
    var responses: JSON!
    var checkout_event:event!
    var parameters: Parameters = [:]
    
    override func viewDidLoad() {
        self.navigationItem.title = "Confirm Order"
    }
    
    @IBAction func paymentConfirmed(_ sender: Any) {
        processSubmissionData()
        
        AF.request(base_url + "/foresite/signUp", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{ response in
            
            do{
                let json = try JSON(data: response.data!)
                if(json["response"] == "success"){
                    
                    print(json)
                    let alert = UIAlertController(title: "Success", message: "Tickets purchased successfully", preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: .cancel, handler: { action in
                                self.performSegue(withIdentifier: "OrderSuccessSegue", sender: self)
                             })
                    
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }catch{
                print("ERROR: Failed to cast to JSON format")
            }
        }
    }
    
    func processSubmissionData(){
        reformatResponses()
        parameters = ["event_id":checkout_event!.id , "user_name":username, "amount_bought": ticket_qty, "qr_code":"temp_code",
                      "add_ons": JSON(add_ons).rawValue, "survey_questions":responses["survey_questions"].rawValue]
        
        print("REQUEST:", parameters)
    }
    
    //reformats responses data to replace array map with corresponding sum
    func reformatResponses(){
        var new_resp = responses["survey_questions"]
        for obj in new_resp{
            var currObj = obj.1
            if(currObj["type"].string! == "multipleChoice" || currObj["type"].string! == "singleChoice"){
                var answers = currObj["answers"]
                for option in answers{
                    let numbers = option.1.arrayObject as! [Int]
                    answers[option.0] = JSON(numbers.reduce(0, +))
                }
                currObj["answers"] = answers
                new_resp[Int(obj.0)!] = currObj
            }
        }
        
        responses["survey_questions"] = new_resp
        
    }
}
