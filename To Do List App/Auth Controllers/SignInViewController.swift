
//
//  SignInViewController.swift
//  To Do List App
//
//  Created by BS236 on 26/1/22.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import Firebase

class SignInViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    var ref: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database(url: "https://to-do-list-app-f7a81-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
    }
    
    @IBAction func googleSignInButtonTapped(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [weak self] user, error in
            
            if error != nil {
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] result, error in
                if error != nil {
                    return
                }
                guard let user = user else { return }
                
                let emailAddress = user.profile?.email
                let givenName = user.profile?.givenName
                let familyName = user.profile?.familyName
                let profilePicUrl = user.profile?.imageURL(withDimension: 320)
                guard let profilePicUrl = profilePicUrl?.absoluteString else {
                    return
                }

                
                guard let userID = Auth.auth().currentUser?.uid else { return }
                
                let data: [String:String] = [
                    "email": emailAddress!,
                    "firstName": givenName!,
                    "lastName":familyName!,
                    "profilePictureURL":profilePicUrl
                ]
                
                self?.ref.child("users").child(userID).setValue(data)
                
                print(result!)
            }
        }
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
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
