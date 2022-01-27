//
//  SignInViewController.swift
//  To Do List App
//
//  Created by BS236 on 26/1/22.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        signInButton.addTarget(self, action: #selector(signInButtonDidTap), for: .touchUpInside)
    }
    
    @objc func signInButtonDidTap() {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
                  print("Field Empty")
                  return
        }
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: {
            result, error in
            guard error == nil else {
                print("Failed to sign in")
                return
            }
            print("Signed In")
        })
    }
}
