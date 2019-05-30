//
//  QRPopupViewController.swift
//  ForeSite
//
//  Created by Bhargava on 5/24/19.
//  Copyright © 2019 Bhargava. All rights reserved.
//

import UIKit

class QRPopupViewController: UIViewController {

    @IBOutlet weak var DoneBtn: RoundButton!
    var QRData: String = ""
    @IBOutlet weak var QRImageView: UIImageView!
    weak var delegate: updateTicketQuantity?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.QRImageView.image = QRData.generateQRCode()
    }

    @IBAction func onDoneClick(_ sender: Any) {
        //print(delegate)
        delegate?.updateTicketQuantity()
        self.dismiss(animated: true)
    }

}
