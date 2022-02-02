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
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    private var authListener: AuthStateDidChangeListenerHandle?
    var ref: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database(url: "https://to-do-list-app-f7a81-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        
        title = "Profile"
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        authListener = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if user == nil {
                self?.askUserToLogin()
            } else {
                self?.userImageView.makeRounded()
                self?.fetchUserData()
            }
        }
        
    }
    
    @IBAction func editProfileButtonTapped(_ sender: Any) {
        
    }
    
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
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
    
    func fetchUserData() {
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        ref.child("users").child(userID).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let firstName = value?["firstName"] as? String ?? ""
            let lastName = value?["lastName"] as? String ?? ""
            let userImageURL = value?["profilePictureURL"] as? String ?? ""
            let email = value?["email"] as? String ?? "Email Missing"
                        
            self?.userNameLabel.text = firstName + " " + lastName
            self?.userEmailLabel.text = email
            
            self?.userImageView.sd_setImage(with: URL(string: userImageURL), placeholderImage: UIImage(named: "defaultUserImage"), options: .continueInBackground, completed: nil)
            
        }) { error in
            print(error.localizedDescription)
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


extension UIImageView {

    func makeRounded() {
        self.layer.borderWidth = 4
        self.layer.masksToBounds = false
        self.layer.borderColor = CGColor(red: 21/255.0, green: 76/255.0, blue: 121/255.0, alpha: 1)
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
    
}
