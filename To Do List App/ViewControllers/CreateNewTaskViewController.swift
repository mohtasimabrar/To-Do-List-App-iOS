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
        TaskService.createNewTask(title: titleTextField.text!, details: detailsTextField.text!)
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
}



