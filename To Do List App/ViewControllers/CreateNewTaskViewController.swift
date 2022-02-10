//
//  CreateNewTaskViewController.swift
//  To Do List App
//
//  Created by BS236 on 1/2/22.
//

import UIKit


class CreateNewTaskViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailsTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
                
        title = "Create New Task"
        
        
    }
    
    @IBAction func saveTaskButtonTapped(_ sender: Any) {
        if let titleText = titleTextField.text, !titleText.isEmpty,
           let detailsText = detailsTextField.text {
            TaskService.createNewTask(title: titleText, details: detailsText)
        } else {
            let alert = AlertService.createAlertController(title: "Error", message: "Title cannot be empty")
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
}



