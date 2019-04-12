//
//  Extensions.swift
//  ForeSite
//
//  Created by Bhargava on 4/7/19.
//  Copyright © 2019 Bhargava. All rights reserved.
//

import Foundation
import CommonCrypto
import UIKit

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
    
    //reference: https://stackoverflow.com/questions/32163848/how-can-i-convert-a-string-to-an-md5-hash-in-ios-using-swift
    func md5() -> String {
        
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, self, CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate()
        var hexString = ""
        for byte in digest {
            hexString += String(format:"%02x", byte)
        }
        
        return hexString
    }
    
}

//reference: https://stackoverflow.com/questions/32281651/how-to-dismiss-keyboard-when-touching-anywhere-outside-uitextfield-in-swift
extension UIViewController{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
