//
//  CompletedTasksViewController.swift
//  To Do List App
//
//  Created by BS236 on 31/1/22.
//

import UIKit
import FirebaseAuth

class CompletedTasksViewController: UIViewController {
    private var authListener: AuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Completed Tasks"

        // Do any additional setup after loading the view.
    }
    

    // Check for auth status some where
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        authListener = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if user == nil {
                self?.askUserToLogin()
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
