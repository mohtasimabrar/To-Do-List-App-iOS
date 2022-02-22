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
    var user: UserProfile?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Profile"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        makePictureRounded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.fetchUserData()
    }
    
    func makePictureRounded() {
        userImageView.layer.borderWidth = 4
        userImageView.layer.masksToBounds = false
        userImageView.layer.borderColor = CGColor(red: 21/255.0, green: 76/255.0, blue: 121/255.0, alpha: 1)
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
        userImageView.clipsToBounds = true
    }
    
    @IBAction func editProfileButtonTapped(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "editProfileView") as? EditProfileViewController {
            guard let user = user else {
                return
            }
            vc.user = user
            present(vc, animated: true, completion: nil)
        }
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
                weakSelf.user = userProfile
                DispatchQueue.main.async {
                    weakSelf.userNameLabel.text = userProfile.firstName + " " + userProfile.lastName
                    weakSelf.userEmailLabel.text = userProfile.email
                    
                    weakSelf.userImageView.sd_setImage(with: URL(string: userProfile.profilePictureURL), placeholderImage: UIImage(named: "defaultUserImage"), options: .continueInBackground, completed: nil)
                }
            }
        }
    }
}
