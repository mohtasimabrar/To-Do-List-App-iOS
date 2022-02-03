//
//  CompletedTasksViewController.swift
//  To Do List App
//
//  Created by BS236 on 31/1/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CompletedTasksViewController: UIViewController {
    private var authListener: AuthStateDidChangeListenerHandle?
    @IBOutlet weak var tableView: UITableView!
    var ref: DatabaseReference!
    var tableViewData = [Task]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Completed Tasks"
        
        ref = Database.database(url: "https://to-do-list-app-f7a81-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        

        // Do any additional setup after loading the view.
    }
    

    // Check for auth status some where
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        authListener = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if user == nil {
                self?.askUserToLogin()
            } else {
                guard let userID = Auth.auth().currentUser?.uid else { return }
                
                self?.ref.child("tasks").child(userID).observe(.value, with: { [weak self] snapshot in
                    var tempTasks = [Task]()
                    for child in snapshot.children {
                        if let childrenSnapshot = child as? DataSnapshot,
                           let dict = childrenSnapshot.value as? [String:Any],
                           let title = dict["title"] as? String,
                           let task = dict["task"] as? String,
                           let isDone = dict["isDone"] as? String,
                           let time = dict["time"] as? String,
                           let date = dict["date"] as? String {
                            if (isDone.elementsEqual("true")){
                                let tempTask = Task(id: childrenSnapshot.key, title: title, task: task, isDone: isDone, time: time, date: date)
                                
                                tempTasks.append(tempTask)
                            }
                        }
                           
                    }
                    
                    self?.tableViewData = tempTasks
                    self?.tableView.reloadData()
                })
            }
        }
    }
    
    private func askUserToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "authNav")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false)
    }

    // Remove the listener once it's no longer needed
    deinit {
        if authListener != nil {
            Auth.auth().removeStateDidChangeListener(authListener!)
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
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive , title: "Delete"){
            [weak self] _, _ , _ in
            let currentTask = self?.tableViewData[indexPath.row]
            guard let userID = Auth.auth().currentUser?.uid else { return }
            self?.ref.child("tasks").child(userID).child(currentTask!.id).removeValue()
        }
        
        let swipeConfig = UISwipeActionsConfiguration(actions: [delete])
        return swipeConfig
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let markAsUndone = UIContextualAction(style: .destructive , title: "Mark As Undone"){
            [weak self] _, _ , _ in
            let currentTask = self?.tableViewData[indexPath.row]
            guard let userID = Auth.auth().currentUser?.uid else { return }
            self?.ref.child("tasks").child(userID).child(currentTask!.id).child("isDone").setValue("false")
        }
        
        let swipeConfig = UISwipeActionsConfiguration(actions: [markAsUndone])
        return swipeConfig
    }
    
}
