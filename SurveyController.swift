//
//  SurveyController.swift
//  
//
//  Created by Bhargava on 5/1/19.
//
//reference for auto layout: http://aplus.rs/2017/one-solution-for-90pct-auto-layout/
import Foundation
import UIKit
import SwiftyJSON

protocol SurveyUpdated: class {
    func multiChoiceUpdated(question: String, answer: String, index: Int, selection:String)
    func singleChoiceUpdated(question: String, answer: String, index: Int)
    func freeResponseUpdated(question: String, answer: String, index: Int)
}

class SurveyController: UIViewController, UITableViewDelegate, UITableViewDataSource, SurveyUpdated{

    
    var checkout_event: event!
    var survey_questions: JSON!
    var add_ons: Array<Any> = []
    var responses: JSON!
    var questionsPerSection = 0

    
    @IBOutlet weak var surveyQuestionsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Survey"
        self.hideKeyboard()
        
        self.surveyQuestionsTableView.delegate = self
        self.surveyQuestionsTableView.dataSource = self
        
        self.surveyQuestionsTableView.rowHeight = 285
        let nibFreeResponse = UINib(nibName: "FreeResponseCell", bundle: nil)
        surveyQuestionsTableView.register(nibFreeResponse, forCellReuseIdentifier: "freeResponseCell")
        
        let nibMultiChoice = UINib(nibName: "MultiChoiceCell", bundle: nil)
        surveyQuestionsTableView.register(nibMultiChoice, forCellReuseIdentifier: "multiChoiceCell")
        
        let nibSingleChoice = UINib(nibName: "SingleChoiceCell", bundle: nil)
        surveyQuestionsTableView.register(nibSingleChoice, forCellReuseIdentifier: "singleChoiceCell")
        
        questionsPerSection = survey_questions!["survey"].count

        print("survey:",survey_questions)
        initializeDataModel()
        

    }
    
    func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.surveyQuestionsTableView.resignFirstResponder()
    }
    
    func multiChoiceUpdated(question: String, answer: String, index: Int, selection:String){ //selection = "select" or "deselect"
        var new_resp = responses["survey_questions"]
        for obj in new_resp{
            var curr_obj:JSON = obj.1
            if(curr_obj["question"].string! == question){
                var answers:JSON = curr_obj["answers"]
                
                if(selection == "select"){
                    answers[answer][index] = 1
                }else if(selection == "deselect"){
                    answers[answer][index] = 0
                }
                curr_obj["answers"] = answers
                new_resp[Int(obj.0)!] = curr_obj
                responses["survey_questions"] = new_resp
                break
            }
        }
        print("UPDATED:", responses["survey_questions"])
    }
    
    func freeResponseUpdated(question: String, answer: String, index: Int){
        var new_resp = responses["survey_questions"]
        for obj in new_resp{
            print("obj.0:", obj.0, "obj.1:", obj.1)
            
            var curr_obj:JSON = obj.1
            if(curr_obj["question"].string! == question){
                var answers:JSON = curr_obj["answers"]
                answers[index] = JSON(answer)
                curr_obj["answers"] = answers
                print("currObj:",curr_obj["answers"])
                new_resp[Int(obj.0)!] = curr_obj
                responses["survey_questions"] = new_resp
                break
            }
        }
        print("UPDATED:", responses["survey_questions"])
    }
    
    func singleChoiceUpdated(question: String, answer: String, index: Int) {
        var new_resp = responses["survey_questions"]
        for obj in new_resp{
            var curr_obj:JSON = obj.1
            if(curr_obj["question"].string! == question){
                var answers:JSON = curr_obj["answers"]
                for option in answers{ //update the array mapping
                    print("option.0:",option.0)
                    if(option.0 == answer){ //if option is the answer selected
                        answers[option.0][index] = 1
                    }else{ //if not the selected option
                        answers[option.0][index] = 0
                    }
                }
                curr_obj["answers"] = answers
                new_resp[Int(obj.0)!] = curr_obj
                responses["survey_questions"] = new_resp
                break
            }
        }
    }
    private func initializeDataModel(){
        responses = ["survey_questions":[]]
        
        for obj in survey_questions! {
            var jsonObj: JSON = obj.1
            var new_jsonObj: JSON = jsonObj
            if(jsonObj["type"].string! == "singleChoice"){
                new_jsonObj["answers"] = [:]
                var firstSet: Bool = false
                for item in jsonObj["answers"].arrayValue {
                    if(firstSet){
                        new_jsonObj["answers"].appendIfDictionary(key: item.string!, json: JSON(Array(repeating: 0, count: ticket_qty)))
                        
                    }else{
                        new_jsonObj["answers"].appendIfDictionary(key: item.string!, json: JSON(Array(repeating: 1, count: ticket_qty)))
                        firstSet = true
                    }
                    
                }
                jsonObj["answers"] = new_jsonObj["answers"]
                
            }else if(jsonObj["type"].string! == "multipleChoice"){
                new_jsonObj["answers"] = [:]
                for item in jsonObj["answers"].arrayValue {
                    new_jsonObj["answers"].appendIfDictionary(key: item.string!, json: JSON(Array(repeating: 0, count: ticket_qty)))
                }
                jsonObj["answers"] = new_jsonObj["answers"]
                
            }else if(jsonObj["type"].string! == "freeResponse"){
                new_jsonObj["answers"] = JSON(Array(repeating: "", count: ticket_qty))
                jsonObj["answers"] = new_jsonObj["answers"]
            }
            responses["survey_questions"].appendIfArray(json: jsonObj)
        }
        print("updated:", responses["survey_questions"].array!)
    }

//    @IBAction func submitSurveyQuestions(_ sender: Any) {
//        surveyQuestionsTableView.reloadData()
//    }
    
    //reference: https://stackoverflow.com/questions/46349740/how-to-preserve-user-input-in-uitableviewcell-before-dequeue
//    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        // do something with the cell before it gets deallocated
//    }
//
    //return number of cells to display per section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return survey_questions.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ticket_qty
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Person \(section+1)"
    }
    
    
    //generate cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("surv:",survey_questions)
        let survey_question = survey_questions[indexPath.row%survey_questions.count]
        if(survey_question["type"] == "freeResponse"){
            print("FREERESP")
            let return_cell = tableView.dequeueReusableCell(withIdentifier: "freeResponseCell", for: indexPath) as! FreeResponseViewCell
            
            return_cell.delegate = self
            return_cell.surveyResponseField.layer.borderWidth = 0.5
            return_cell.surveyResponseField.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            return_cell.indexPath = indexPath.section
            
            return_cell.surveyQuestionLabel.text = survey_question["question"].string!
            return_cell.surveyResponseField.text = getFreeResponseText(index: indexPath.section, question: survey_question["question"].string!)
            return return_cell
        }
        
        if(survey_question["type"] == "multipleChoice"){
            print("MULTICHOICE")
            let return_cell = tableView.dequeueReusableCell(withIdentifier: "multiChoiceCell", for: indexPath) as! MultipleChoiceViewCell
            return_cell.delegate = self
            return_cell.surveyQuestionLabel.text = survey_question["question"].string!
            return_cell.options = survey_question["answers"].arrayObject as! [String]
            return_cell.indexPath = indexPath.section
            print(return_cell.options)
            return_cell.selectedOptions = getMultiSelectedOptions(question: survey_question["question"].string!)
            DispatchQueue.main.async {
                return_cell.optionsList.reloadData()
            }
            
            return return_cell
        }
        if (survey_question["type"] == "singleChoice"){
            print("SINGLECHOICE")
            let return_cell = tableView.dequeueReusableCell(withIdentifier: "singleChoiceCell", for: indexPath) as! SingleResponseViewCell

            return_cell.delegate = self
            return_cell.surveyQuestionLabel.text = survey_question["question"].string
            return_cell.pickerData = survey_question["answers"].arrayObject as! [String]
            return_cell.indexPath = indexPath.section
            let strSelectedOption: String = getSelectedOption(index: indexPath.section, question: survey_question["question"].string!)
            print("selected:",strSelectedOption)
            let idx: Int? = return_cell.pickerData.firstIndex(of: strSelectedOption)
            //print("idx:", idx!)
            if(idx != nil){
                return_cell.singlePickerView.selectRow(idx!, inComponent:0, animated: false)
            }else{
                return_cell.singlePickerView.selectRow(0, inComponent:0, animated: false)
            }
            return return_cell
        }
//        let return_cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
        let return_cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "DefaultCell")
        return return_cell
    }
    
    func getMultiSelectedOptions(question:String) -> JSON{
        let new_resp = responses["survey_questions"]
        //let arr_idx = (indexPath.row/new_resp.count)
        for obj in new_resp{
            var curr_obj:JSON = obj.1
            if(curr_obj["question"].string! == question){
                return curr_obj["answers"]
            }
        }
        return []
    }
    func getFreeResponseText(index: Int, question:String) -> String{
        let new_resp = responses["survey_questions"]
        //let arr_idx = (indexPath.row/new_resp.count)
        for obj in new_resp{
            var curr_obj:JSON = obj.1
            if(curr_obj["question"].string! == question){
                let answers:[String] = curr_obj["answers"].arrayObject as! [String]
                return answers[index]
            }
        }
        return ""
    }
    func getSelectedOption(index: Int, question: String) -> String{
        let new_resp = responses["survey_questions"]
        //let arr_idx = (indexPath.row/new_resp.count)
        for obj in new_resp{
            var curr_obj:JSON = obj.1
            if(curr_obj["question"].string! == question){
                let answers:JSON = curr_obj["answers"]
                for option in answers{
                    if(option.1.arrayObject![index] as! Int == 1){
                        return option.0
                    }
                }
                return ""
            }
        }
        return ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "paymentSegue" {
            if let destination = segue.destination as? PaymentController {
                destination.checkout_event = checkout_event
                destination.add_ons = add_ons
                destination.responses = responses
            }
        }
    }
}
