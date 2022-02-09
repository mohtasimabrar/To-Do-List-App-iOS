//
//  TaskViewController.swift
//  To Do List App
//
//  Created by BS236 on 4/2/22.
//

import UIKit


class TaskViewController: UIViewController {
    @IBOutlet weak var taskStateLabel: UILabel!
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var taskDetailsLabel: UILabel!
    
    var task:Task?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        title = "View Task"
        
        viewConfiguration()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let markAsDoneButton = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .done , target: self, action: #selector(markAsDone))
        let deleteTaskButton = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain , target: self, action: #selector(deleteTask))
        let markAsUndoneButton = UIBarButtonItem(image: UIImage(systemName: "arrow.uturn.backward"), style: .plain , target: self, action: #selector(markAsUndone))
        let editTaskButton = UIBarButtonItem(image: UIImage(systemName: "highlighter"), style: .plain , target: self, action: #selector(editTask))
        
        if let task = task {
            if (task.isDone.elementsEqual("false")){
                navigationItem.rightBarButtonItems = [markAsDoneButton,editTaskButton, deleteTaskButton]
            } else {
                navigationItem.rightBarButtonItems = [markAsUndoneButton, deleteTaskButton]
            }
        }
        
    }
    
    
    @objc func editTask() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "editTask") as? EditTaskViewController {
            vc.task = self.task
            vc.editTaskDelegate = self
            present(vc, animated: true, completion: nil)
            //navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    @objc func deleteTask() {
        if let task = task {
            TaskService.deleteTask(id: task.id)
        }
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    
    @objc func markAsDone() {
        if let task = task {
            TaskService.markTaskAsDone(id: task.id)
        }
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    
    @objc func markAsUndone() {
        if let task = task {
            TaskService.markTaskAsUndone(id: task.id)
        }
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    
    func viewConfiguration() {
        if let task = task {
            titleTextLabel!.text = task.title
            timeLabel.text = task.time + ","
            dateLabel.text = task.date
            taskDetailsLabel.text = task.task
            if task.isDone.elementsEqual("false"){
                taskStateLabel.text = "Incomplete"
                taskStateLabel.backgroundColor = .red
                taskStateLabel.textColor = .white
                taskStateLabel.layer.cornerRadius = 6
                taskStateLabel.layer.masksToBounds = true
            } else {
                taskStateLabel.text = "Complete"
                taskStateLabel.backgroundColor = UIColor(red: 50/255, green: 205/255, blue: 50/255, alpha: 1)
                taskStateLabel.textColor = .white
                taskStateLabel.layer.cornerRadius = 6
                taskStateLabel.layer.masksToBounds = true
            }
        }
    }
    
}


extension TaskViewController: EditTaskDelegate {
    func didDismissView(task: Task) {
        self.task = task
        self.viewConfiguration()
    }
}
