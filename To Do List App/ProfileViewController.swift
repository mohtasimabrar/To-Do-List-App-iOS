//
//  ProfileViewController.swift
//  To Do List App
//
//  Created by BS236 on 31/1/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    private var authListener: AuthStateDidChangeListenerHandle?
    var ref: DatabaseReference!
    
    let signOutButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database(url: "https://to-do-list-app-f7a81-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        
        title = "Profile"
        
        createSignOutButton()
        fetchUserData()
        
        
        //        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: signOutButton)
        
        // Do any additional setup after loading the view.
    }
    
    func fetchUserData() {
        
        let userID = Auth.auth().currentUser?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let firstName = value?["firstName"] as? String ?? ""
            let lastName = value?["lastName"] as? String ?? ""
            let userImageURL = value?["profilePictureURL"] as? String ?? ""
            
            print(userImageURL)
            
            self?.userNameLabel.text = firstName + " " + lastName
            self?.userImageView.sd_setImage(with: URL(string: userImageURL), placeholderImage: UIImage(named: "defaultUserImage"), options: .continueInBackground, completed: nil)
            
        }) { error in
            print(error.localizedDescription)
        }
    }
    
    func createSignOutButton() {
        signOutButton.setTitle("Sign Out", for: .normal)
        signOutButton.setTitleColor(.white , for: .normal)
        signOutButton.backgroundColor = UIColor(red: 21/255.0, green: 76/255.0, blue: 121/255.0, alpha: 1)
        signOutButton.frame = CGRect(x: 15, y: -50, width: 100, height: 30)
        //signOutButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 50, bottom: 10, trailing: 50)
        signOutButton.layer.cornerRadius = 8
        signOutButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)
    }
    
    
    @objc func signOut(){
        do {
            try FirebaseAuth.Auth.auth().signOut()
            self.userImageView.image = UIImage(named: "defaultUserImage")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "authNav")
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true)
        }
        catch {
            print("An Error Occured")
        }
        
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
