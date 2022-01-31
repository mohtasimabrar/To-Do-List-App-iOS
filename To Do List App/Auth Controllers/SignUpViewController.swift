//
//  SignUpViewController.swift
//  To Do List App
//
//  Created by BS236 on 26/1/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController {
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    var ref: DatabaseReference!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database(url: "https://to-do-list-app-f7a81-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
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
            [weak self] result, error in
            guard error == nil else {
                print("Failed to create")
                print(error!)
                return
            }
            
            guard let userID = Auth.auth().currentUser?.uid else { return }
            
            self?.ref.child("users").child(userID).child("firstName").setValue(self?.firstNameTextField.text)
            self?.ref.child("users").child(userID).child("lastName").setValue(self?.lastNameTextField.text)
            
            self?.dismiss(animated: true, completion: nil)
            print("Account Created")
        })
        
    }

}
