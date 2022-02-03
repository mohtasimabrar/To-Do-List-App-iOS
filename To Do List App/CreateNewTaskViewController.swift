//
//  CreateNewTaskViewController.swift
//  To Do List App
//
//  Created by BS236 on 1/2/22.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class CreateNewTaskViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailsTextField: UITextField!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        ref = Database.database(url: "https://to-do-list-app-f7a81-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        
        title = "Create New Task"
    }
    
    @IBAction func saveTaskButtonTapped(_ sender: Any) {
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let date = Date()
        let calendar = Calendar.current

        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        print("hours = \(hour):\(minutes):\(seconds)")
        
        let data: [String:String] = [
            "isDone": "false",
            "task": detailsTextField.text!,
            "title":titleTextField.text!,
            "time": "\(hour):\(minutes):\(seconds)",
            "date": Date.getCurrentDate()
        ]
        
        print(data)
        self.ref.child("tasks").child(userID).childByAutoId().setValue(data)
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
        
    }
}


extension Date {
    static func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: Date())
    }
}
