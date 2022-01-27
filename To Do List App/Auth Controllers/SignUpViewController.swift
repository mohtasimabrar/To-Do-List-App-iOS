//
//  SignUpViewController.swift
//  To Do List App
//
//  Created by BS236 on 26/1/22.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        registerButton.addTarget(self, action: #selector(registerButtonDidTap), for: .touchUpInside)
        
    }
    
    @objc func registerButtonDidTap() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
                  print("Field Empty")
                  return
        }
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {
            result, error in
            guard error == nil else {
                print("Failed to create")
                return
            }
            print("Account Created")
        })
    }

}
