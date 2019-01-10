//
//  UIButtonExtension.swift
//  ForeSite
//
//  Created by Bhargava on 1/9/19.
//  Copyright © 2019 Bhargava. All rights reserved.
//  Extensions add new functionality to existing class, struct, enum, or protocol type.

import Foundation
import UIKit

extension UIButton {
    func flash(){
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.2 //animation duration
        flash.fromValue = 1 //initial value for keypath property
        flash.toValue = 0.2 //after value for keyPath
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true //loop
        flash.repeatCount = 1 //# loops
        
        layer.add(flash, forKey: nil)
    }
}
