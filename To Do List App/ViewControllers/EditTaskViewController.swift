//
//  EditTaskViewController.swift
//  To Do List App
//
//  Created by BS236 on 8/2/22.
//

import UIKit

class EditTaskViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailsTextField: UITextField!
    
    var task:Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        if let titleText = titleTextField.text,
           let detailsText = detailsTextField.text,
           let taskID = task?.id
           {
            
            TaskService.saveTask(id: taskID, title: titleText, details: detailsText)
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
}
