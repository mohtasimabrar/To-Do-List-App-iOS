//
//  HomeViewController.swift
//  To Do List App
//
//  Created by BS236 on 31/1/22.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var tableViewData = [Task]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "To Do List"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose , target: self, action: #selector(addNewTask))
    }
    
    // Check for auth status some where
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        TaskService.getUndoneTasks { [weak self] tasks in
            guard let weakSelf = self else { return }
            if let tasks = tasks {
                weakSelf.tableViewData = tasks
                DispatchQueue.main.async {
                    weakSelf.tableView.reloadData()
                }
            }
        }
    }
    
    @objc func addNewTask() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "newTask") as? CreateNewTaskViewController {
            //self.present(vc, animated: true, completion: nil)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
        
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
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
        let markAsDone = UIContextualAction(style: .normal , title: "Mark As Done"){
            [weak self] _, _ , _ in
            if let currentTask = self?.tableViewData[indexPath.row] {
                TaskService.markTaskAsDone(id: currentTask.id)
            }
        }
        
        markAsDone.backgroundColor =  UIColor(red: 50/255, green: 205/255, blue: 50/255, alpha: 1)
        let swipeConfig = UISwipeActionsConfiguration(actions: [markAsDone])
        return swipeConfig
    }
    
}
