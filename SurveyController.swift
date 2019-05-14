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

class SurveyController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var checkout_event: event!
    var survey_questions: JSON!
    var add_ons: Array<Any> = []
    var questionsPerSection = 0
    @IBOutlet weak var surveyQuestionsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Survey"
        
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
        print(survey_questions)
        print(survey_questions!["survey"].count)
    }
    
    @IBAction func submitSurveyQuestions(_ sender: Any) {
        surveyQuestionsTableView.reloadData()
    }
    
    //reference: https://stackoverflow.com/questions/46349740/how-to-preserve-user-input-in-uitableviewcell-before-dequeue
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // do something with the cell before it gets deallocated
    }
    
    //return number of cells to display per section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return survey_questions["survey"].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ticket_qty
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Person \(section+1)"
    }
    //generate cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let survey_question = survey_questions["survey"][indexPath.row%survey_questions["survey"].count]
        print(survey_question)
        if(survey_question["type"] == "freeResponse"){
            print("FREERESP")
//            let return_cell = FreeResponseViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "freeResponseCell")
            let return_cell = tableView.dequeueReusableCell(withIdentifier: "freeResponseCell", for: indexPath) as! FreeResponseViewCell
            return_cell.surveyQuestionLabel.text = survey_question["question"].string!
            return_cell.surveyResponseField.layer.borderWidth = 0.5
            return_cell.surveyResponseField.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
            return return_cell
        }
        
        if(survey_question["type"] == "multipleChoice"){
            print("MULTICHOICE")
            let return_cell = tableView.dequeueReusableCell(withIdentifier: "multiChoiceCell", for: indexPath) as! MultipleChoiceViewCell
//            let return_cell = MultipleChoiceViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "multiChoiceCell")
            return_cell.surveyQuestionLabel.text = survey_question["question"].string!
            return_cell.options = survey_question["answers"].arrayObject as! [String]
            print(return_cell.options)

            DispatchQueue.main.async {
                return_cell.optionsList.reloadData()
            }
            
            return return_cell
        }
        if (survey_question["type"] == "singleChoice"){
            let return_cell = tableView.dequeueReusableCell(withIdentifier: "singleChoiceCell", for: indexPath) as! SingleResponseViewCell
//            let return_cell = SingleResponseViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "singleChoiceCell")
            print(survey_question["question"].string!)
            return_cell.surveyQuestionLabel.text = survey_question["question"].string
            return_cell.pickerData = survey_question["answers"].arrayObject as! [String]
            return return_cell
        }
//        let return_cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
        let return_cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "DefaultCell")
        return return_cell
    }

}
//to-do: store data in nested array, update data before dequeue, loop through cells
//store array of selected cells
