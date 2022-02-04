//
//  TaskService.swift
//  To Do List App
//
//  Created by BS236 on 4/2/22.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase


class TaskService {
    static var ref = Database.database(url: Constants.dataBastURL).reference()
        
    static func createNewTask(title: String, details: String) {
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let data: [String:String] = [
            "isDone": "false",
            "task": details,
            "title": title,
            "time": Date.getCurrentTime(),
            "date": Date.getCurrentDate()
        ]
        
        self.ref.child("tasks").child(userID).childByAutoId().setValue(data)
    }
    
    static func deleteTask(id: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        self.ref.child("tasks").child(userID).child(id).removeValue()
    }
    
    static func markTaskAsDone(id: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        self.ref.child("tasks").child(userID).child(id).child("isDone").setValue("true")
    }
    
    static func markTaskAsUndone(id: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        self.ref.child("tasks").child(userID).child(id).child("isDone").setValue("false")
    }
    
    static func getUndoneTasks(completionHandler: @escaping ([Task]?)->()) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        self.ref.child("tasks").child(userID).observe(.value, with: { snapshot in
            var tempTasks = [Task]()
            for child in snapshot.children {
                if let childrenSnapshot = child as? DataSnapshot,
                   let dict = childrenSnapshot.value as? [String:Any],
                   let title = dict["title"] as? String,
                   let task = dict["task"] as? String,
                   let isDone = dict["isDone"] as? String,
                   let time = dict["time"] as? String,
                   let date = dict["date"] as? String {
                    if (isDone.elementsEqual("false")){
                        let tempTask = Task(id: childrenSnapshot.key, title: title, task: task, isDone: isDone, time: time, date: date)
                        
                        tempTasks.append(tempTask)
                    }
                }
            }
            completionHandler(tempTasks)
        })
    }
    
    static func getDoneTasks(completionHandler: @escaping ([Task]?)->()) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        self.ref.child("tasks").child(userID).observe(.value, with: { snapshot in
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
            completionHandler(tempTasks)
        })
    }
}
