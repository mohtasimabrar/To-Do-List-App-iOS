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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Profile"
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.fetchUserData()
        self.userImageView.makeRounded()
        
    }
    
    @IBAction func editProfileButtonTapped(_ sender: Any) {
        
    }
    
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
        do {
            try FirebaseAuth.Auth.auth().signOut()
            self.userImageView.image = UIImage(named: "defaultUserImage")
        }
        catch {
            print("An Error Occured")
        }
    }
    
    func fetchUserData() {
        
        guard let userID = Auth.auth().currentUser?.uid else { return }

        UserService.observeUserProfile(userID) { [weak self] userProfile in
            guard let weakSelf = self else { return }
            if let userProfile = userProfile {
                DispatchQueue.main.async {
                    weakSelf.userNameLabel.text = userProfile.firstName + " " + userProfile.lastName
                    weakSelf.userEmailLabel.text = userProfile.email
                    
                    weakSelf.userImageView.sd_setImage(with: URL(string: userProfile.profilePictureURL), placeholderImage: UIImage(named: "defaultUserImage"), options: .continueInBackground, completed: nil)
                }
            }
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
