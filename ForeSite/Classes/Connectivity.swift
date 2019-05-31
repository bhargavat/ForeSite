//
//  Connectivity.swift
//  ForeSite
//
//  Created by Bhargava on 5/31/19.
//  Copyright © 2019 Bhargava. All rights reserved.
//  ref: https://stackoverflow.com/questions/41327325/how-to-check-internet-connection-in-alamofire

import Foundation
import Alamofire
class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}
