
//
//  SignInViewController.swift
//  To Do List App
//
//  Created by BS236 on 26/1/22.
//

import UIKit
import FBSDKLoginKit

class SignInViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var FacebookLoginButton: FBLoginButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let token = AccessToken.current,
                !token.isExpired {
                // User is logged in, do work such as go to next view controller.
        } else {
//            FacebookLoginButton.permissions = ["public_profile", "email"]
//            FacebookLoginButton.delegate = self
            let loginButton = FBLoginButton()
            loginButton.center = view.center
            view.addSubview(loginButton)
            loginButton.permissions = ["public_profile", "email"]
            loginButton.delegate = self
        }
    }
    
    @IBAction func googleSignInButtonTapped(_ sender: Any) {
        UserService.googleSignIn(view: self) { error in
            if let error = error {
                let alert = AlertService.createAlertController(title: "Error", message: error.localizedDescription)
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
                  let alert = AlertService.createAlertController(title: "Error", message: "Please fill up all fields")
                  self.present(alert, animated: true, completion: nil)
                  return
              }
        UserService.signIn(email: email, password: password) { error in
            if let error = error {
                let alert = AlertService.createAlertController(title: "Error", message: error.localizedDescription)
                self.present(alert, animated: true, completion: nil)
                return
            }

        }
        
    }
    
}


extension SignInViewController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        let token = result?.token?.tokenString
        let request = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields":"email,name"], tokenString: token, version: nil, httpMethod: .get)
        request.start { (connection, result, error) in
            print("\(result)")
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Log Out")
    }
    
    
}
