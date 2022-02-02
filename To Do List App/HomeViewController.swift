//
//  HomeViewController.swift
//  To Do List App
//
//  Created by BS236 on 31/1/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController {
    private var authListener: AuthStateDidChangeListenerHandle?
    var ref: DatabaseReference!
    var tableViewData = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database(url: "https://to-do-list-app-f7a81-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        
        
        title = "To Do List"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose , target: self, action: #selector(addNewTask))
    }
    
    // Check for auth status some where
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        authListener = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if user == nil {
                self?.askUserToLogin()
            } else {
                guard let userID = Auth.auth().currentUser?.uid else { return }
                
                self?.ref.child("tasks").child(userID).observe(.value, with: { snapshot in
                    guard let dt = snapshot.value else { return }
                    print(dt)
                })
                
                print(self?.tableViewData)
            }
        }
    }
    
    @objc func addNewTask() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "newTask") as? CreateNewTaskViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
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

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
}
