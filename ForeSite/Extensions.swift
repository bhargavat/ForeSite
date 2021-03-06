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
import SwiftyJSON

//A set of object extensions to support application-related needs
extension Double {
    func roundTo(places:Int) -> String {
        return String(format: "%.\(places)f", self)
    }
    
    func dollarRound() -> String {
        return String(format: "%.\(2)f", self)
    }
    func dollarRoundDouble() -> Double {
        return Double(String(format: "%.\(2)f", self))!
    }
}

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
    
    func reformatDate(fromFormat:String, toFormat:String) -> String {
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = fromFormat
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = toFormat
        
        if let date = dateFormatterGet.date(from: self) {
            return dateFormatterPrint.string(from: date)
        } else {
            return self
        }
    }
    
    //ref: https://stackoverflow.com/questions/48944184/swift-generate-a-qrcode?rq=1
    func generateQRCode() -> UIImage? {
        let data = self.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 5, y: 5)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    //ref: https://www.hackingwithswift.com/articles/108/how-to-use-regular-expressions-in-swift
    //ex: "hat" ~= "[a-z]at"
    static func ~= (lhs: String, rhs: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
        let range = NSRange(location: 0, length: lhs.utf16.count)
        return regex.firstMatch(in: lhs, options: [], range: range) != nil
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

//ref: https://stackoverflow.com/questions/54455940/swift-4-2-make-bottom-of-tableview-move-up-when-keyboard-shows
extension UITableView {
    
    func setBottomInset(to value: CGFloat) {
        let edgeInset = UIEdgeInsets(top: 0, left: 0, bottom: value, right: 0)
        
        self.contentInset = edgeInset
        self.scrollIndicatorInsets = edgeInset
    }
}

//reference: https://stackoverflow.com/questions/29046255/how-to-append-new-data-to-an-existing-json-arrayswiftyjson
extension JSON{
    mutating func appendIfArray(json:JSON){
        if var arr = self.array{
            arr.append(json)
            self = JSON(arr);
        }
    }
    
    mutating func appendIfDictionary(key:String,json:JSON){
        if var dict = self.dictionary{
            dict[key] = json;
            self = JSON(dict);
        }
    }
}

