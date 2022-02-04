//
//  CompletedTasksViewController.swift
//  To Do List App
//
//  Created by BS236 on 31/1/22.
//

import UIKit

class CompletedTasksViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var tableViewData = [Task]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Completed Tasks"
    }
    
    
    // Check for auth status some where
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        TaskService.getDoneTasks{ [weak self] tasks in
            guard let weakSelf = self else { return }
            if let tasks = tasks {
                
                weakSelf.tableViewData = tasks
                DispatchQueue.main.async {
                    weakSelf.tableView.reloadData()
                }
            }
        }
    }
}


extension CompletedTasksViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TasksTableViewCell else {
            return UITableViewCell()
        }
        
        let currentTask = tableViewData[indexPath.row]
        
        cell.cellConfiguration(currentTask)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "taskViewController") as? TaskViewController {
            vc.task = self.tableViewData[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive , title: "Delete"){
            [weak self] _, _ , _ in
            if let currentTask = self?.tableViewData[indexPath.row] {
                TaskService.deleteTask(id: currentTask.id)
            }
        }
        
        let swipeConfig = UISwipeActionsConfiguration(actions: [delete])
        return swipeConfig
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let markAsUndone = UIContextualAction(style: .destructive , title: "Mark As Undone"){
            [weak self] _, _ , _ in
            if let currentTask = self?.tableViewData[indexPath.row] {
                TaskService.markTaskAsUndone(id: currentTask.id)
            }
        }
        
        let swipeConfig = UISwipeActionsConfiguration(actions: [markAsUndone])
        return swipeConfig
    }
    
}
