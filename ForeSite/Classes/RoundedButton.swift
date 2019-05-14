//
//  RoundedButton.swift
//  ForeSite
//
//  Created by Bhargava on 4/16/19.
//  Copyright © 2019 Bhargava. All rights reserved.
// reference: https://stackoverflow.com/questions/38874517/how-to-make-a-simple-rounded-button-in-storyboard

import UIKit

@IBDesignable
class RoundButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0{
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear{
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
}
