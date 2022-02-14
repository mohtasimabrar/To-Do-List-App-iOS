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
        self.initializeHideKeyboard()
        
        titleTextField.delegate = self
        detailsTextField.delegate = self
        
    }
    
    @IBAction func saveTaskButtonTapped(_ sender: Any) {
        
        guard let titleText = titleTextField.text, !titleText.isEmpty,
              let detailsText = detailsTextField.text,
              let navController = self.navigationController else {
                   let alert = AlertService.createAlertController(title: "Error", message: "Title cannot be empty")
                   self.present(alert, animated: true, completion: nil)
                   return
              }
        
        TaskService.createNewTask(title: titleText, details: detailsText)
        navController.popViewController(animated: true)
        
    }
}



