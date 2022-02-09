//
//  ForgotPasswordViewController.swift
//  To Do List App
//
//  Created by BS236 on 8/2/22.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        
        guard let email = emailTextField.text, !email.isEmpty else {
            let alert = AlertService.createAlertController(title: "Error", message: "An Email address must be provided")
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        UserService.resetPassword(for: email) { error in
            if let error = error {
                let alert = AlertService.createAlertController(title: "Error", message: error.localizedDescription)
                self.present(alert, animated: true, completion: nil)
                return
            }
            let alert = AlertService.createAlertController(title: "Success", message: "A password reset email has been sent to '\(email)'")
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
}
