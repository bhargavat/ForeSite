//
//  EventViewController.swift
//  ForeSite
//
//  Created by Bhargava on 2/6/19.
//  Copyright © 2019 Bhargava. All rights reserved.
//  Reference: https://www.youtube.com/watch?v=v0Hx7q26Hoo (segue from tableview cell)
//
import UIKit

class EventViewController: UIViewController {
    
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
