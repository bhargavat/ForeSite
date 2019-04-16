//
//  CellData.swift
//  ForeSite
//
//  Created by Bhargava on 1/29/19.
//  Copyright © 2019 Bhargava. All rights reserved.
//  Reference: https://www.ralfebert.de/ios-examples/uikit/uitableviewcontroller/custom-cells/

import UIKit
import Foundation

struct event {
    var id: String
    var title : String
    var startDay : String
    var startTime : String
    var endDay: String
    var endTime : String
    var price : String
    var location : String
    var image : UIImage
}

class EventTableViewCell: UITableViewCell{
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventStart: UILabel!
    @IBOutlet weak var eventEnd: UILabel!
    @IBOutlet weak var eventPrice: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventLocation: UILabel!
}
