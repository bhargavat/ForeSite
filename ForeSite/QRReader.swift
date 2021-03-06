//
//  QRReader.swift
//  ForeSite
//
//  QR Reader to scan foresite-generated tickets and mark them as redeemed
//  Created by Bhargava on 5/24/19.
//  Copyright © 2019 Bhargava. All rights reserved.
// ref: https://www.hackingwithswift.com/example-code/media/how-to-scan-a-barcode

import Foundation
import AVFoundation
import UIKit
import Alamofire
import SwiftyJSON

class QRReader: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var closeButton: UIButton!
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    @IBOutlet weak var aimer: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        self.view.bringSubviewToFront(aimer)
        self.view.bringSubviewToFront(closeButton)
        captureSession.startRunning()
    }
    
    @IBAction func dismissScanner(_ sender: Any) {
        captureSession.stopRunning()
        dismiss(animated: true)
    }
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        print("meta: ",metadataObjects)
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            if(stringValue ~= "[a-z0-9]{24}[:][0-9]{1}"){
                found(code: stringValue)
            }else{
                let alert = UIAlertController(title: "Invalid Ticket", message: "Please try again", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                    self.captureSession.startRunning()
                }))
                self.present(alert, animated: true)
            }
        }
        
        
        //dismiss(animated: true)
    }
    
    //function to execute after successful QR code
    func found(code: String) {
        print(code)
        let data = code.split(separator: ":")
        print("data:",data)
        let parameters: Parameters = ["ticket_id":data[0],"tickets_redeemed": Int(data[1])!]
        AF.request(base_url + "/foresite/redeemTickets", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{ response in
            
            do{
                let json = try JSON(data: response.data!)
                if(json["response"] == "error"){
                    let alert = UIAlertController(title: "Invalid Tickets", message: "Ticket(s) have been previously redeemed.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                        self.captureSession.startRunning()
                    }))
                    self.present(alert, animated: true)
                }
                if(json["response"] == "success"){
                    
                    print(json)
                    let alert = UIAlertController(title: "Success", message: "Tickets redeemed successfully", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                        self.captureSession.startRunning()
                    }))
                    self.present(alert, animated: true)
                }
            }catch{
                print("ERROR: Failed to cast to JSON format")
            }
        }
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    
}
