//
//  CellData.swift
//  ForeSite
//
//  Created by Bhargava on 1/29/19.
//  Copyright © 2019 Bhargava. All rights reserved.
//  Reference: https://www.ralfebert.de/ios-examples/uikit/uitableviewcontroller/custom-cells/

import UIKit
import Foundation
import SwiftyJSON

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
    var add_ons : Array<Any>
}

struct add_on {
    var title: String
    var quantity: Int
    var price: Double
}

class EventTableViewCell: UITableViewCell{
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventStart: UILabel!
    @IBOutlet weak var eventEnd: UILabel!
    @IBOutlet weak var eventPrice: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventLocation: UILabel!
}

//reference: https://medium.com/@georgetsifrikas/embedding-uitextview-inside-uitableviewcell-9a28794daf01
class FreeResponseViewCell: UITableViewCell, UITextViewDelegate{
    @IBOutlet weak var surveyQuestionLabel: UILabel!
    @IBOutlet weak var surveyResponseField: UITextView!
    weak var delegate: SurveyUpdated?
    var indexPath: Int = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        surveyResponseField.delegate = self
    }
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        delegate?.freeResponseUpdated(question: surveyQuestionLabel.text!, answer: textView.text!, index: indexPath)
        print(textView.text!) //the textView parameter is the textView where text was changed
    }
}

class SingleResponseViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {

    weak var delegate: SurveyUpdated?
    @IBOutlet weak var surveyQuestionLabel: UILabel!
    @IBOutlet weak var singlePickerView: UIPickerView!
    var indexPath: Int = -1 //updated to which section it belongs to
    var pickerData = [String](){
        didSet{
            self.singlePickerView.dataSource = self
            self.singlePickerView.delegate = self
        }
    }
//    let optionPicker = UIPickerView()
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let index = self.singlePickerView.selectedRow(inComponent: component)
        print("indexPath:",self.indexPath)
        delegate?.singleChoiceUpdated(question: surveyQuestionLabel.text!, answer: self.pickerData[index], index: self.indexPath)
    }
    
    func getIndexPath() -> IndexPath? {
        guard let superView = self.superview as? UITableView else {
            print("superview is not a UITableView - getIndexPath")
            return nil
        }
        let indexPath: IndexPath? = superView.indexPath(for: self)
        return indexPath
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
}

//reference: https://stackoverflow.com/questions/17398058/is-it-possible-to-add-uitableview-within-a-uitableviewcell

class MultipleChoiceViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource{
    weak var delegate: SurveyUpdated?
    var indexPath: Int = -1 //row of 
    var selectedOptions: JSON = []
    @IBOutlet weak var surveyQuestionLabel: UILabel!
    @IBOutlet weak var optionsList: UITableView!{
        didSet{
            self.optionsList.delegate = self
            self.optionsList.dataSource = self
            self.optionsList.rowHeight = 45
            
            let nibOptionCell = UINib(nibName: "SimpleTableCell", bundle: nil)
            self.optionsList.register(nibOptionCell, forCellReuseIdentifier: "SimpleTableCell")
            self.optionsList.reloadData()
        }
    }
    var options = [String](){
        didSet{
            self.optionsList.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SimpleTableViewCell{
//            print(cell.optionLabel.text!)
//            print(indexPath.row)
            delegate?.multiChoiceUpdated(question: surveyQuestionLabel.text!, answer: cell.optionLabel.text!, index: self.indexPath, selection: "select")
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SimpleTableViewCell{
//            print(cell.optionLabel.text!)
//            print(indexPath.row)
            delegate?.multiChoiceUpdated(question: surveyQuestionLabel.text!, answer: cell.optionLabel.text!, index: self.indexPath, selection: "deselect")
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("options")
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("celly")
        let return_cell = tableView.dequeueReusableCell(withIdentifier: "SimpleTableCell", for: indexPath) as! SimpleTableViewCell

        return_cell.optionLabel.text = options[indexPath.row]
        print(options[indexPath.row],":",selectedOptions[options[indexPath.row]])
        if(selectedOptions != []){
            if(selectedOptions[options[indexPath.row]][self.indexPath] == 1){
                self.optionsList.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)

            }
        }
        
        return return_cell
    }
    
}

class SimpleTableViewCell: UITableViewCell{
    @IBOutlet weak var optionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

class AddOnTableViewCell: UITableViewCell{
    
    weak var delegate: AddOnUpdated?
    @IBOutlet weak var addonLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var quantityStepper: UIStepper!
    var quantity : Int = 0
    //ref: https://stackoverflow.com/questions/42876739/swift-increment-label-with-stepper-in-tableview-cell
    @IBAction func quantityStep(_ sender: UIStepper) {
        if(Int(sender.value) <= ticket_qty){
            self.quantity = Int(sender.value)
            self.quantityLabel.text = String(quantity)
            self.quantityStepper.value = Double(quantity)
            var title = addonLabel.text!
            if let index = title.range(of: " (+$"){
                title = String(title[..<index.lowerBound])
            }
            delegate?.quantityUpdated(label: title, value: self.quantity)
            
        }
    }
}

class OrderTableViewCell: UITableViewCell{
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventEndLabel: UILabel!
    @IBOutlet weak var eventStartLabel: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventPurchaseDate: UILabel!
}
