//
//  ProfileViewController.swift
//  To Do List App
//
//  Created by BS236 on 31/1/22.
//

import UIKit
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
    
    override func viewDidLayoutSubviews() {
        self.userImageView.makeRounded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.fetchUserData()
    }
    
    @IBAction func editProfileButtonTapped(_ sender: Any) {
        
    }
    
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
        UserService.signOut { [weak self] state in
            guard let weakSelf = self else { return }
            if state == nil {
                DispatchQueue.main.async {
                    weakSelf.userImageView.image = UIImage(named: "defaultUserImage")
                }
            }
        }
           
    }
    
    func fetchUserData() {

        UserService.getUserData { [weak self] userProfile in
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
