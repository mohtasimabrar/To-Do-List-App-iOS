//
//  EditTaskViewController.swift
//  To Do List App
//
//  Created by BS236 on 8/2/22.
//

import UIKit

protocol EditTaskDelegate: AnyObject {
    func didDismissView (task: Task)
}

class EditTaskViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailsTextField: UITextField!
    
    var task:Task?
    
    weak var editTaskDelegate: EditTaskDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializeHideKeyboard()
        titleTextField.delegate = self
        detailsTextField.delegate = self
        
        initiateNavBar()
        loadViewData()

    }
    
    func initiateNavBar() {
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        view.addSubview(navBar)

        let navItem = UINavigationItem(title: "Edit Task")
        let doneItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(cancelEdit))
        navItem.rightBarButtonItem = doneItem

        navBar.setItems([navItem], animated: false)
    }
    
    func loadViewData() {
        if let task = task {
            titleTextField.text = task.title
            detailsTextField.text = task.task
        }
    }
    
    @objc func cancelEdit() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        guard let titleText = titleTextField.text, !titleText.isEmpty,
              let detailsText = detailsTextField.text, let task = task,
              let editTaskDelegate = editTaskDelegate else {
                  let alert = AlertService.createAlertController(title: "Error", message: "Title cannot be empty")
                  self.present(alert, animated: true, completion: nil)
                  return
              }
        
        let updatedTask = Task(id: task.id, title: titleText, task: detailsText, isDone: "false", time: Date.getCurrentTime(), date: Date.getCurrentDate())
            
        TaskService.saveTask(task: updatedTask)
        
        editTaskDelegate.didDismissView(task: updatedTask)
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
