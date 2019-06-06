//
//  GlobalData.swift
//  ForeSite
//
//  Created by Bhargava on 4/7/19.
//  Copyright © 2019 Bhargava. All rights reserved.
//

import Foundation

//user currently logged in
var username:String = ""

//base url of REST API server
let base_url:String = "https://0bdd038e.ngrok.io"

//ticket_qty selected by user at checkout
var ticket_qty = 0

//chosen event's subtotal and total price
var selected_event_subtotal: Double = 0.0 //price per base ticket
var selected_event_total: Double = 0.00
