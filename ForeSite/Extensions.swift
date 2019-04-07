//
//  Extensions.swift
//  ForeSite
//
//  Created by Bhargava on 4/7/19.
//  Copyright © 2019 Bhargava. All rights reserved.
//

import Foundation

extension String {
    //Validate Email
    var isEmail: Bool {
        let regex = try! NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    
    //Validate Phone Number
    var isPhoneNumber: Bool {
        let regex = try! NSRegularExpression(pattern: "[0-9]{10}", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    
    
}
